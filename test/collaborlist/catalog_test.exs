defmodule Collaborlist.CatalogTest do
  use Collaborlist.DataCase

  alias Collaborlist.Catalog
  alias Collaborlist.List

  describe "lists" do
    alias Collaborlist.Catalog.List

    import Collaborlist.CatalogFixtures
    import Collaborlist.ListFixtures

    @invalid_attrs %{title: 42, checked: "foo", striked: "bar"}

    test "list_lists/0 returns all lists" do
      list = list_fixture()
      assert Catalog.list_lists() == [list]
    end

    test "get_list!/1 returns the list with given id" do
      list = list_fixture()
      assert Catalog.get_list!(list.id) == list
    end

    test "create_list/1 with valid data creates a list" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %List{} = list} = Catalog.create_list(valid_attrs)
      assert list.title == "some title"
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_list(@invalid_attrs)
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
      assert list == Catalog.get_list!(list.id)
    end

    test "delete_list/1 deletes the list" do
      list = list_fixture()
      assert {:ok, %List{}} = Catalog.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_list!(list.id) end
    end

    test "delete_list/1 deletes all list items of deleted list" do
      # TODO
      list = list_fixture()
      list_item = list_item_fixture()
      assert {:ok, %List{}} = Catalog.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_list!(list.id) end
    end

    test "change_list/1 returns a list changeset" do
      list = list_fixture()
      assert %Ecto.Changeset{} = Catalog.change_list(list)
    end
  end
end
