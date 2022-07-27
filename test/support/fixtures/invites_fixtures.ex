defmodule Collaborlist.InvitesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Collaborlist.List` context.
  """

  import Collaborlist.CatalogFixtures
  import Collaborlist.AccountFixtures

  @doc """
  Generates an invite
  """
  def invite_fixture(user \\ user_fixture(), list \\ list_fixture()) do
    {:ok, invite} = Collaborlist.Invites.create_invite(user, list)

    invite
  end
end
