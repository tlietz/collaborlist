defmodule CollaborlistWeb.UserAuthTest do
  use CollaborlistWeb.ConnCase, async: true

  alias Collaborlist.Account
  alias CollaborlistWeb.UserAuth
  import Collaborlist.AccountFixtures
  import Collaborlist.InvitesFixtures
  import Collaborlist.CatalogFixtures

  @remember_me_cookie "_collaborlist_web_user_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, CollaborlistWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: user_fixture(), conn: conn}
  end

  describe "log_in_user/3" do
    test "stores the user token in the session", %{conn: conn, user: user} do
      conn = UserAuth.log_in_user(conn, user)
      assert token = get_session(conn, :user_token)
      assert get_session(conn, :live_socket_id) == "users_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == "/"
      assert Account.get_user_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, user: user} do
      conn = conn |> put_session(:to_be_removed, "value") |> UserAuth.log_in_user(user)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, user: user} do
      conn = conn |> put_session(:user_return_to, "/hello") |> UserAuth.log_in_user(user)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, user: user} do
      conn = conn |> fetch_cookies() |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
      assert get_session(conn, :user_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :user_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_user/1" do
    test "erases session and cookies", %{conn: conn, user: user} do
      user_token = Account.generate_user_session_token(user)

      conn =
        conn
        |> put_session(:user_token, user_token)
        |> put_req_cookie(@remember_me_cookie, user_token)
        |> fetch_cookies()
        |> UserAuth.log_out_user()

      refute get_session(conn, :user_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      refute Account.get_user_by_session_token(user_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "users_sessions:abcdef-token"
      CollaborlistWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> UserAuth.log_out_user()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if user is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> UserAuth.log_out_user()
      refute get_session(conn, :user_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_user/2" do
    test "authenticates user from session", %{conn: conn, user: user} do
      user_token = Account.generate_user_session_token(user)
      conn = conn |> put_session(:user_token, user_token) |> UserAuth.fetch_current_user([])
      assert conn.assigns.current_user.id == user.id
    end

    test "authenticates user from cookies", %{conn: conn, user: user} do
      logged_in_conn =
        conn |> fetch_cookies() |> UserAuth.log_in_user(user, %{"remember_me" => "true"})

      user_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> UserAuth.fetch_current_user([])

      assert get_session(conn, :user_token) == user_token
      assert conn.assigns.current_user.id == user.id
    end

    test "does not authenticate if data is missing", %{conn: conn, user: user} do
      _ = Account.generate_user_session_token(user)
      conn = UserAuth.fetch_current_user(conn, [])
      refute get_session(conn, :user_token)
      refute conn.assigns.current_user
    end
  end

  describe "redirect_if_user_is_logged_in/2" do
    test "redirects if user is not a guest", %{conn: conn, user: user} do
      conn = conn |> assign(:current_user, user) |> UserAuth.redirect_if_user_is_logged_in([])
      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "does not redirect if there is no user", %{conn: conn} do
      conn = UserAuth.redirect_if_user_is_logged_in(conn, [])
      refute conn.halted
      refute conn.status
    end

    test "does not redirect if the user is a guest", %{conn: conn} do
      guest_user = guest_user_fixture()

      conn =
        conn
        |> assign(:current_user, guest_user)
        |> UserAuth.redirect_if_user_is_logged_in([])

      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_user/2" do
    test "redirects if user is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> UserAuth.require_authenticated_user([])
      assert conn.halted
      assert redirected_to(conn) == Routes.list_path(conn, :index)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn.halted
      assert get_session(halted_conn, :user_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn.halted
      assert get_session(halted_conn, :user_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn.halted
      refute get_session(halted_conn, :user_return_to)
    end

    test "does not redirect if user is authenticated", %{conn: conn, user: user} do
      conn = conn |> assign(:current_user, user) |> UserAuth.require_authenticated_user([])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_user_list_collaborator/2" do
    test "redirects if user is not a list collaborator", %{conn: conn} do
      list = list_fixture()
      other_user = user_fixture()

      conn =
        %{conn | params: %{"list_id" => list.id}}
        |> assign(:current_user, other_user)
        |> fetch_flash()
        |> UserAuth.require_user_list_collaborator([])

      assert conn.halted
      assert redirected_to(conn) == Routes.list_path(conn, :index)
      assert get_flash(conn, :error) =~ "collaborator on the list"
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      list = list_fixture()
      other_user = user_fixture()

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "", params: %{"list_id" => list.id}}
        |> assign(:current_user, other_user)
        |> fetch_flash()
        |> UserAuth.require_user_list_collaborator([])

      assert halted_conn.halted
      assert get_session(halted_conn, :user_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz", params: %{"list_id" => list.id}}
        |> assign(:current_user, other_user)
        |> fetch_flash()
        |> UserAuth.require_user_list_collaborator([])

      assert halted_conn.halted
      assert get_session(halted_conn, :user_return_to) == "/foo?bar=baz"

      halted_conn =
        %{
          conn
          | path_info: ["foo"],
            query_string: "bar",
            method: "POST",
            params: %{"list_id" => list.id}
        }
        |> assign(:current_user, other_user)
        |> fetch_flash()
        |> UserAuth.require_user_list_collaborator([])

      assert halted_conn.halted
      refute get_session(halted_conn, :user_return_to)
    end

    test "does not redirect if user is a collaborator", %{conn: conn, user: user} do
      list = list_fixture(%{}, user)

      conn =
        %{conn | params: %{"list_id" => list.id}}
        |> assign(:current_user, user)
        |> UserAuth.require_user_list_collaborator([])

      refute conn.halted
      refute conn.status
    end
  end

  describe "require_user_invite_creator/2" do
    test "redirects if user is not an invite creator", %{conn: conn} do
      invite = invite_fixture(user_fixture(), list_fixture())
      other_user = user_fixture()

      conn =
        %{conn | params: %{"invite_code" => invite.invite_code}}
        |> assign(:current_user, other_user)
        |> fetch_flash()
        |> UserAuth.require_user_invite_creator([])

      assert conn.halted
      assert redirected_to(conn) == Routes.list_path(conn, :index)
      assert get_flash(conn, :error) =~ "invite creator"
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      other_user = user_fixture()

      invite = invite_fixture(user_fixture(), list_fixture())

      halted_conn =
        %{
          conn
          | path_info: ["foo"],
            query_string: "",
            params: %{"invite_code" => invite.invite_code}
        }
        |> assign(:current_user, other_user)
        |> fetch_flash()
        |> UserAuth.require_user_invite_creator([])

      assert halted_conn.halted
      assert get_session(halted_conn, :user_return_to) == "/foo"

      halted_conn =
        %{
          conn
          | path_info: ["foo"],
            query_string: "bar=baz",
            params: %{"invite_code" => invite.invite_code}
        }
        |> assign(:current_user, other_user)
        |> fetch_flash()
        |> UserAuth.require_user_invite_creator([])

      assert halted_conn.halted
      assert get_session(halted_conn, :user_return_to) == "/foo?bar=baz"

      halted_conn =
        %{
          conn
          | path_info: ["foo"],
            query_string: "bar",
            method: "POST",
            params: %{"invite_code" => invite.invite_code}
        }
        |> assign(:current_user, other_user)
        |> fetch_flash()
        |> UserAuth.require_user_invite_creator([])

      assert halted_conn.halted
      refute get_session(halted_conn, :user_return_to)
    end

    test "does not redirect if user is the invite creator", %{conn: conn, user: user} do
      invite = invite_fixture(user, list_fixture())

      conn =
        %{conn | params: %{"invite_code" => invite.invite_code}}
        |> assign(:current_user, user)
        |> UserAuth.require_user_invite_creator([])

      refute conn.halted
      refute conn.status
    end
  end

  describe "maybe_guest_flash/2" do
    test "does not put flash if user is logged into an account", %{conn: conn} do
      conn =
        conn
        |> fetch_flash()
        |> UserAuth.log_in_user(user_fixture())
        |> UserAuth.fetch_current_user([])
        |> UserAuth.maybe_guest_flash([])

      assert get_flash(conn, :info) == nil
    end

    test "puts flash if user is a guest", %{conn: conn} do
      conn =
        conn
        |> fetch_flash()
        |> UserAuth.log_in_user(guest_user_fixture())
        |> UserAuth.fetch_current_user([])
        |> UserAuth.maybe_guest_flash([])

      assert get_flash(conn, :info) =~ "Logged in as guest"
    end

    test "does not put flash if an :info flash already exists", %{conn: conn} do
      conn =
        conn
        |> fetch_flash()
        |> UserAuth.log_in_user(guest_user_fixture())
        |> UserAuth.fetch_current_user([])
        |> put_flash(:info, "info")
        |> UserAuth.maybe_guest_flash([])

      refute get_flash(conn, :info) =~ "Logged in as guest"
    end
  end
end
