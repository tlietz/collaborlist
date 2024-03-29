defmodule CollaborlistWeb.ListControllerTest do
  use CollaborlistWeb.ConnCase

  import Collaborlist.CatalogFixtures

  alias CollaborlistWeb.UserAuth
  alias Collaborlist.Catalog

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: 4, checked: "foo", striked: "bar"}

  setup :register_and_log_in_user

  describe "index" do
    setup [:create_list]

    test "lists all lists that belongs to a user", %{conn: conn, list: list} do
      [user] = list.users

      conn =
        log_in_user(conn, user)
        |> UserAuth.fetch_current_user(%{})
        |> get(Routes.list_path(conn, :index))

      assert html_response(conn, 200) =~ ~s/#{list.title}/
    end
  end

  describe "new list" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.list_path(conn, :new))
      assert html_response(conn, 200) =~ "New List"
    end
  end

  describe "create list" do
    test "redirects to collab index of list when data is valid", %{conn: conn} do
      conn = post(conn, Routes.list_path(conn, :create), list: @create_attrs)

      assert %{list_id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.collab_path(conn, :index, id)

      list = Catalog.get_list!(id)
      conn = get(conn, Routes.collab_path(conn, :index, id))
      assert html_response(conn, 200) =~ list.title
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.list_path(conn, :create), list: @invalid_attrs)

      assert html_response(conn, 200) =~ "New List"
    end
  end

  describe "edit list" do
    setup [:create_list]

    test "renders form for editing chosen list", %{conn: conn, list: list} do
      [user] = list.users

      conn =
        log_in_user(conn, user)
        |> UserAuth.fetch_current_user(%{})
        |> get(Routes.list_path(conn, :edit, list))

      assert html_response(conn, 200) =~ "Edit List"
    end
  end

  describe "update list" do
    setup [:create_list]

    test "redirects when data is valid", %{conn: conn, list: list} do
      [user] = list.users

      conn =
        log_in_user(conn, user)
        |> UserAuth.fetch_current_user(%{})
        |> put(Routes.list_path(conn, :update, list), list: @update_attrs)

      assert redirected_to(conn) == Routes.list_path(conn, :index)

      # conn = get(conn, Routes.collab_path(conn, :index, list))
      # assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, list: list} do
      [user] = list.users

      conn =
        log_in_user(conn, user)
        |> UserAuth.fetch_current_user(%{})
        |> put(Routes.list_path(conn, :update, list), list: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit List"
    end
  end

  describe "delete list" do
    setup [:create_list]

    test "deletes chosen list", %{conn: conn, list: list} do
      [user] = list.users

      conn =
        log_in_user(conn, user)
        |> UserAuth.fetch_current_user(%{})
        |> delete(Routes.list_path(conn, :delete, list))

      assert redirected_to(conn) == Routes.list_path(conn, :index)
    end
  end

  defp create_list(_) do
    list = list_fixture()

    %{list: list}
  end
end
