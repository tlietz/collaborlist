defmodule CollaborlistWeb.InvitesControllerTest do
  use CollaborlistWeb.ConnCase

  import Collaborlist.CatalogFixtures
  import Collaborlist.AccountFixtures
  import Collaborlist.InvitesFixtures

  alias CollaborlistWeb.UserAuth
  alias Collaborlist.Invites

  setup :register_and_log_in_user

  describe "index" do
    # test "lists all invites that belongs to a user", %{conn: conn} do
    #   user = user_fixture()
    #   list = list_fixture(%{}, user)

    #   invite = invite_fixture(user, list)

    #   conn =
    #     log_in_user(conn, user)
    #     |> UserAuth.fetch_current_user(%{})
    #     |> get(Routes.invites_path(conn, :index, list.id))

    #   assert html_response(conn, 200) =~ ~s/#{invite.invite_code}/
    # end

    # test "redirects if user is not a collaborator on the list", %{conn: conn} do
    #   user = user_fixture()
    #   list = list_fixture()

    #   conn =
    #     log_in_user(conn, user)
    #     |> UserAuth.fetch_current_user(%{})
    #     |> get(Routes.invites_path(conn, :index, list.id))

    #   assert html_response(conn, 302)
    # end
  end

  # describe "create invite" do
  #   test "redirects to invites index of a list collaborator when data is valid", %{conn: conn} do
  #     user = user_fixture()
  #     list = list_fixture(%{}, user)

  #     conn =
  #       log_in_user(conn, user)
  #       |> UserAuth.fetch_current_user(%{})
  #       |> post(Routes.invites_path(conn, :create, list.id))

  #     assert %{list_id: id} = redirected_params(conn)

  #     assert redirected_to(conn) == Routes.invites_path(conn, :index, id)

  #     [invite | _] = Invites.list_invites(id)

  #     conn = get(conn, Routes.invites_path(conn, :index, id))
  #     assert html_response(conn, 200) =~ invite.invite_code
  #   end
  # end

  describe "delete invite" do
    # test "deletes chosen list", %{conn: conn} do
    #   user = user_fixture()
    #   list = list_fixture(%{}, user)
    #   invite = invite_fixture(user, list)

    #   conn =
    #     log_in_user(conn, user)
    #     |> UserAuth.fetch_current_user(%{})
    #     |> delete(Routes.invites_path(conn, :delete, list.id, invite.invite_code))

    #   assert redirected_to(conn) == Routes.invites_path(conn, :index, list.id)

    #   assert Invites.get_invite(invite.invite_code) == nil
    # end
  end

  describe "process invite" do
    test "redirects to website index when invite code is invalid", %{conn: conn} do
      user = user_fixture()

      conn =
        log_in_user(conn, user)
        |> UserAuth.fetch_current_user(%{})
        |> get(Routes.invites_path(conn, :process_invite, "invalid-code"))

      assert redirected_to(conn) == Routes.list_path(conn, :index)
    end

    test "redirects to list invite belongs to when invite code is valid", %{conn: conn} do
      user = user_fixture()
      list = list_fixture(%{}, user)
      invite = invite_fixture(user, list)

      conn =
        log_in_user(conn, user)
        |> UserAuth.fetch_current_user(%{})
        |> get(Routes.invites_path(conn, :process_invite, invite.invite_code))

      assert redirected_to(conn) == Routes.collab_path(conn, :index, invite.list_id)
    end
  end
end
