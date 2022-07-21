defmodule Collaborlist.Invites do
  @moduledoc """
  The Invites context.
  """

  import Ecto.Query, warn: false
  alias Collaborlist.Repo

  alias Collaborlist.Invites.Invite
  alias Collaborlist.Account.User
  alias Collaborlist.Catalog

  @doc """
  Returns the list of all invites.
  """
  def list_invites(%User{} = user) do
    Repo.all(from invite in Invite, where: invite.user_id == ^user.id)
  end

  def list_invites(list_id) do
    Repo.all(from invite in Invite, where: invite.list_id == ^list_id)
  end

  @doc """
  Gets a single invite.
  """
  def get_invite!(invite_code), do: Repo.get!(Invite, invite_code)

  @doc """
  Gets a single invite.
  """
  def get_invite(invite_code), do: Repo.get(Invite, invite_code)

  @doc """
  Creates an invite.
  """
  def create_invite(%Catalog.List{} = list, %User{} = user, attrs \\ %{}) do
    %Invite{}
    |> Map.put(:list_id, list.id)
    |> Map.put(:user_id, user.id)
    |> Invite.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns true if the user is the creator of an invite, false otherwise.
  """
  def invite_creator?(invite_code, %User{} = user) do
  end
end
