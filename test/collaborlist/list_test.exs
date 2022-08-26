defmodule Collaborlist.ListTest do
  use Collaborlist.DataCase

  alias Collaborlist.List

  describe "list_items" do
    alias Collaborlist.List.ListItem

    import Collaborlist.CatalogFixtures
    import Collaborlist.ListFixtures

    @invalid_attrs %{content: 42, status: "foo"}

    test "list_list_items/0 returns all list_items" do
      list_item = list_item_fixture()

      Enum.zip(List.list_list_items(list_item.list_id), [list_item])
      |> Enum.each(fn {got, want} ->
        unless got.id == want.id do
          raise "expected a database read of all list items to be the same as the created list items"
        end
      end)
    end

    test "get_list_item!/1 returns the list_item with given id and correct list_id" do
      list_item = list_item_fixture()
      got = List.get_list_item!(list_item.id)
      assert got.id == list_item.id
      assert got.list_id == list_item.list_id
    end

    test "create_list_item/1 with valid data creates a list_item" do
      valid_attrs = %{content: "some content", status: :none}

      assert {:ok, %ListItem{} = list_item} = List.create_list_item(valid_attrs, list_fixture())

      assert list_item.content == "some content"
      assert list_item.status == :none
      assert list_item.list_id != nil
    end

    test "create_list_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = List.create_list_item(@invalid_attrs, list_fixture())
    end

    test "update_list_item/2 with valid data updates the list_item" do
      list_item = list_item_fixture()
      update_attrs = %{content: "some updated content", status: :checked}

      assert {:ok, %ListItem{} = list_item} = List.update_list_item(list_item, update_attrs)

      assert list_item.content == "some updated content"
      assert list_item.status == :checked

      update_attrs = %{status: :striked}

      assert {:ok, %ListItem{} = list_item} = List.update_list_item(list_item, update_attrs)
      assert list_item.status == :striked
    end

    test "update_list_item/2 with invalid data returns error changeset" do
      list_item = list_item_fixture()
      assert {:error, %Ecto.Changeset{}} = List.update_list_item(list_item, @invalid_attrs)
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
