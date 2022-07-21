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

      invite = invite_fixture(list, user)

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
    end

    test "get_invite!/1 returns the invite with the given invite_code" do
      invite = invite_fixture()

      got = Invites.get_invite!(invite.invite_code)
      assert got.invite_code == invite.invite_code
    end

    test "create_invite/2 creates an invite" do
      user = user_fixture()
      list = list_fixture(%{}, user)

      assert {:ok, %Invite{} = invite} = Invites.create_invite(list, user)

      assert invite.list_id == list.id
      assert invite.user_id == user.id
    end

    test "invite_creator?/2 returns true if the user is a creator of an invite, false otherwise" do
      user = user_fixture()
      list = list_fixture()

      {:ok, invite} = Invites.create_invite(list, user)

      assert Invites.invite_creator?(invite.invite_code, user) == true

      user2 = user_fixture()

      assert Invites.invite_creator?(invite.invite_code, user2) == false
    end
  end
end
