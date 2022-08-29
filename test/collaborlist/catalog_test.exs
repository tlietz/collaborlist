defmodule Collaborlist.CatalogTest do
  use Collaborlist.DataCase

  alias Collaborlist.Catalog

  alias Collaborlist.Catalog.List

  import Collaborlist.CatalogFixtures
  import Collaborlist.AccountFixtures
  import Collaborlist.ListFixtures
  import Collaborlist.InvitesFixtures

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

    test "delete_list/2 does not delete the list entirely if there are still collaborators on it" do
      user = user_fixture()

      list = list_fixture(%{}, user)

      user2 = user_fixture()

      _ = Catalog.add_collaborator(list, user2)

      Catalog.list_collaborators(list)

      _ = Catalog.delete_list(user, list)

      assert Catalog.list_collaborator?(user2, list.id) == true
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

      assert Catalog.list_collaborator?(user, list.id) == true
    end

    test "list_collaborator?/2 returns false if a user is not a collaborator on a list" do
      list = list_fixture()
      list2 = list_fixture()

      [user] = list.users

      assert Catalog.list_collaborator?(user, list2.id) == false
    end

    test "add_collaborator(%Invite{}, %User{})/2 adds a user as a collaborator to a list" do
      invite = invite_fixture()

      user = user_fixture()

      assert Catalog.list_collaborator?(user, invite.list_id) == false

      _ = Catalog.add_collaborator(invite, user)

      assert Catalog.list_collaborator?(user, invite.list_id) == true
    end

    test "add_collaborator(%List{}, %User{})/2 adds a user as a collaborator to a list" do
      list = list_fixture()

      [user1] = list.users

      user2 = user_fixture()

      assert Catalog.list_collaborator?(user1, list.id) == true
      assert Catalog.list_collaborator?(user2, list.id) == false

      _ = Catalog.add_collaborator(list, user2)

      assert Catalog.list_collaborator?(user1, list.id) == true
      assert Catalog.list_collaborator?(user2, list.id) == true
    end

    test "remove_collaborator/2 removes a user as a collaborator" do
      list = list_fixture()

      [user1] = list.users

      user2 = user_fixture()

      assert Catalog.list_collaborator?(user1, list.id) == true
      assert Catalog.list_collaborator?(user2, list.id) == false

      _ = Catalog.add_collaborator(list, user2)

      assert Catalog.list_collaborator?(user1, list.id) == true
      assert Catalog.list_collaborator?(user2, list.id) == true

      _ = Catalog.remove_collaborator(list, user1)

      assert Catalog.list_collaborator?(user1, list.id) == false
      assert Catalog.list_collaborator?(user2, list.id) == true
    end

    test "list_collaborators/1 returns a list of collaborators ids" do
      list = list_fixture()
      user = user_fixture()
      _ = Catalog.add_collaborator(list, user)

      assert Catalog.list_collaborators(list) |> Enum.count() == 2
    end
  end
end
