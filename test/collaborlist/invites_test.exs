defmodule Collaborlist.InvitesTest do
  use Collaborlist.DataCase

  alias Collaborlist.Invites

  import Collaborlist.CatalogFixtures
  import Collaborlist.ListFixtures
  import Collaborlist.AccountFixtures

  describe "invites" do
    alias Collaborlist.Invites.Invite

    @invalid_attrs %{content: 42, striked: "foo", checked: "bar"}

    test "create_invite/2 creates an invite" do
      list = list_fixture()
      user = user_fixture()
      assert {:ok, %Invite{} = invite} = Invites.create_invite(list, user)

      assert invite.list_id == list.id
      assert invite.user_id == user.id
    end
  end
end
