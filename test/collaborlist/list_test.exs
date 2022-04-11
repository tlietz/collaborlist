defmodule Collaborlist.ListTest do
  use Collaborlist.DataCase

  alias Collaborlist.List

  describe "list_items" do
    alias Collaborlist.List.ListItem

    import Collaborlist.ListFixtures

    @invalid_attrs %{content: nil}

    test "list_list_items/0 returns all list_items" do
      list_item = list_item_fixture()
      assert List.list_list_items() == [list_item]
    end

    test "get_list_item!/1 returns the list_item with given id" do
      list_item = list_item_fixture()
      assert List.get_list_item!(list_item.id) == list_item
    end

    test "create_list_item/1 with valid data creates a list_item" do
      valid_attrs = %{content: "some content", striked: false, checked: false}

      assert {:ok, %ListItem{} = list_item} = List.create_list_item(valid_attrs)

      assert list_item.content == "some content"
      assert list_item.striked == false
      assert list_item.checked == false
    end

    test "create_list_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = List.create_list_item(@invalid_attrs)
    end

    test "update_list_item/2 with valid data updates the list_item" do
      list_item = list_item_fixture()
      update_attrs = %{content: "some updated content", striked: true, checked: true}

      assert {:ok, %ListItem{} = list_item} = List.update_list_item(list_item, update_attrs)
      assert list_item.content == "some updated content"
      assert list_item.striked == true
      assert list_item.checked == true
    end

    test "update_list_item/2 with invalid data returns error changeset" do
      list_item = list_item_fixture()
      assert {:error, %Ecto.Changeset{}} = List.update_list_item(list_item, @invalid_attrs)
      assert list_item == List.get_list_item!(list_item.id)
    end

    test "delete_list_item/1 deletes the list_item" do
      list_item = list_item_fixture()
      assert {:ok, %ListItem{}} = List.delete_list_item(list_item)
      assert_raise Ecto.NoResultsError, fn -> List.get_list_item!(list_item.id) end
    end

    test "change_list_item/1 returns a list_item changeset" do
      list_item = list_item_fixture()
      assert %Ecto.Changeset{} = List.change_list_item(list_item)
    end
  end
end
