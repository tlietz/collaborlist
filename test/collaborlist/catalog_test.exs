defmodule Collaborlist.CatalogTest do
  use Collaborlist.DataCase

  alias Collaborlist.Catalog

  alias Collaborlist.Catalog.List

  import Collaborlist.CatalogFixtures
  import Collaborlist.AccountFixtures
  import Collaborlist.ListFixtures

  describe "lists" do
    @invalid_attrs %{title: 42, checked: "foo", striked: "bar"}

    test "list_lists/0 returns only lists that belong to a user" do
      list = list_fixture()

      [user] = list.users
      _list2 = list_fixture()

      lists = Catalog.list_lists(user)
      assert length(lists) == 1

      [first_user_list] = lists
      assert first_user_list.id == list.id
    end

    test "get_list!/1 returns the list with given id" do
      list = list_fixture()
      assert Catalog.get_list!(list.id).id == list.id
    end

    test "create_list/1 with valid data creates a list" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %List{} = list} = Catalog.create_list(user_fixture(), valid_attrs)
      assert list.title == "some title"
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_list(user_fixture(), @invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      list = list_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %List{} = list} = Catalog.update_list(list, update_attrs)
      assert list.title == "some updated title"
    end

    test "update_list/2 with invalid data returns error changeset" do
      list = list_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_list(list, @invalid_attrs)
      assert list.id == Catalog.get_list!(list.id).id
    end

    test "delete_list/1 deletes the list" do
      list = list_fixture()
      assert {:ok, %List{}} = Catalog.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_list!(list.id) end
    end

    test "delete_list/1 deletes the list and all list items of that list" do
      list = list_fixture()
      list_item = list_item_fixture(%{}, list)

      assert {:ok, %List{}} = Catalog.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> Collaborlist.List.get_list_item!(list_item.id) end
    end

    test "change_list/1 returns a list changeset" do
      list = list_fixture()
      assert %Ecto.Changeset{} = Catalog.change_list(list)
    end
  end

  describe "list collaborators" do
    test "list_collaborator?/2 returns true if a user is a collaborator on a list" do
      list = list_fixture()

      [user] = list.users

      assert Catalog.list_collaborator?(list.id, user) == true
    end

    test "list_collaborator?/2 returns false if a user is not a collaborator on a list" do
      list = list_fixture()
      list2 = list_fixture()

      [user] = list.users

      assert Catalog.list_collaborator?(list2.id, user) == false
    end
  end
end
