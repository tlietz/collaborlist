defmodule Collaborlist.InvitesTest do
  use Collaborlist.DataCase

  alias Collaborlist.Invites
  alias Collaborlist.Invites.Invite

  import Collaborlist.CatalogFixtures
  import Collaborlist.AccountFixtures
  import Collaborlist.InvitesFixtures

  describe "invites" do
    test "list_invites/1 returns all expected invites" do
      user = user_fixture()
      list = list_fixture(%{}, user)

      invite = invite_fixture(user, list)

      Enum.zip(Invites.list_invites(user), [user])
      |> Enum.each(fn {got, want} ->
        unless got.user_id == want.id do
          raise "expected listing an invite of user to match the invite"
        end
      end)

      Enum.zip(Invites.list_invites(invite.list_id), [list])
      |> Enum.each(fn {got, want} ->
        unless got.list_id == want.id do
          raise "expected listing an invite of list to match the invite"
        end
      end)

      _invite2 = invite_fixture(user_fixture(), list_fixture())

      Enum.zip(Invites.list_invites(user, invite.list_id), [user, list])
      |> Enum.each(fn {got, want} ->
        unless got.user_id == want.id and got.list_id == list.id do
          raise "expected listing an invite of user and list to match the invite"
        end
      end)
    end

    test "get_invite!/1 returns the invite with the given invite_code" do
      invite = invite_fixture()

      got = Invites.get_invite!(invite.invite_code)
      assert got.invite_code == invite.invite_code
    end

    test "invite_code_valid? returns true if the code is valid, false otherwise" do
      assert Invites.invite_code_valid?("invalid-code") == false

      invite = invite_fixture()
      assert Invites.invite_code_valid?(invite.invite_code) == true
    end

    test "create_invite/2 creates an invite" do
      user = user_fixture()
      list = list_fixture(%{}, user)

      assert {:ok, %Invite{} = invite} = Invites.create_invite(user, list)

      assert invite.list_id == list.id
      assert invite.user_id == user.id
    end

    test "create_invite/2 returns an error if more than max invites are trying to be created" do
      user = user_fixture()
      list = list_fixture(%{}, user)

      max_invites = Collaborlist.Helpers.max_invites()

      for _ <- 0..(max_invites - 1) do
        {:ok, %Invite{} = _invite} = Invites.create_invite(user, list)
      end

      assert {:error, _} = Invites.create_invite(user, list)

      assert Invites.list_invites(user, list.id) |> Enum.count() == max_invites
    end

    test "invite_creator?/2 returns true if the user is a creator of an invite, false otherwise" do
      user = user_fixture()
      list = list_fixture()

      {:ok, invite} = Invites.create_invite(user, list)

      assert Invites.invite_creator?(user, invite.invite_code) == true

      user2 = user_fixture()

      assert Invites.invite_creator?(user2, invite.invite_code) == false
    end
  end
end
