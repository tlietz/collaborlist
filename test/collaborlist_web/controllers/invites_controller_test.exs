defmodule CollaborlistWeb.InvitesControllerTest do
  use CollaborlistWeb.ConnCase

  import Collaborlist.CatalogFixtures
  import Collaborlist.AccountFixtures
  import Collaborlist.InvitesFixtures

  alias CollaborlistWeb.UserAuth
  alias Collaborlist.Catalog
  alias Collaborlist.Invites

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: 4, checked: "foo", striked: "bar"}

  setup :register_and_log_in_user

  describe "index" do
    test "lists all invites that belongs to a user", %{conn: conn} do
      user = user_fixture()
      list = list_fixture(%{}, user)

      invite = invite_fixture(user, list)

      conn =
        log_in_user(conn, user)
        |> UserAuth.fetch_current_user(%{})
        |> get(Routes.invites_path(conn, :index, list.id))

      assert html_response(conn, 200) =~ ~s/#{invite.invite_code}/
    end

    test "redirects if user is not a collaborator on the list", %{conn: conn} do
      user = user_fixture()
      list = list_fixture()

      invite = invite_fixture(user, list)

      conn =
        log_in_user(conn, user)
        |> UserAuth.fetch_current_user(%{})
        |> get(Routes.invites_path(conn, :index, list.id))

      assert html_response(conn, 302)
    end
  end

  describe "create invite" do
    test "redirects to invites index of a list collaborator when data is valid", %{conn: conn} do
      user = user_fixture()
      list = list_fixture(%{}, user)

      conn =
        log_in_user(conn, user)
        |> UserAuth.fetch_current_user(%{})
        |> post(Routes.invites_path(conn, :create, list.id))

      assert %{list_id: id} = redirected_params(conn)

      assert redirected_to(conn) == Routes.invites_path(conn, :index, id)

      [invite | _] = Invites.list_invites(id)

      conn = get(conn, Routes.invites_path(conn, :index, id))
      assert html_response(conn, 200) =~ invite.invite_code
    end
  end
end
