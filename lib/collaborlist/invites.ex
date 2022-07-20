defmodule Collaborlist.Invites do
  @moduledoc """
  The Invites context.
  """

  import Ecto.Query, warn: false
  alias Collaborlist.Repo

  alias Collaborlist.Invites.Invite

  @doc """
  Returns the list of all invites to a list.

  """
  def list_invites(list_id) do
    Repo.all(from li in Invite, where: li.list_id == ^list_id)
  end
end
