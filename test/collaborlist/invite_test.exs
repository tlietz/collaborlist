defmodule Collaborlist.InviteTest do
  use Collaborlist.DataCase

  alias Collaborlist.Invite

  describe "invites" do
    alias Collaborlist.Invites.Invite

    import Collaborlist.CatalogFixtures
    import Collaborlist.ListFixtures

    @invalid_attrs %{content: 42, striked: "foo", checked: "bar"}
  end
end
