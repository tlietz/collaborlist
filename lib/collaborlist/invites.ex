defmodule Collaborlist.Invites do
  @moduledoc """
  The Invites context.
  """

  import Ecto.Query, warn: false
  alias Collaborlist.Repo

  alias Collaborlist.Invites.Invite
  alias Collaborlist.Account.User
  alias Collaborlist.Catalog

  @max_invites Collaborlist.Helpers.max_invites()

  @doc """
  Returns the list of all invites.
  """
  def list_invites(%User{} = user) do
    Repo.all(from invite in Invite, where: invite.user_id == ^user.id)
  end

  def list_invites(list_id) do
    Repo.all(from invite in Invite, where: invite.list_id == ^list_id)
  end

  def list_invites(%User{} = user, list_id) do
    Repo.all(
      from invite in Invite, where: invite.list_id == ^list_id and invite.user_id == ^user.id
    )
  end

  @doc """
  Gets a single invite. Raises an error if the invite does not exist
  """
  def get_invite!(invite_code), do: Repo.get!(Invite, invite_code)

  @doc """
  Gets a single invite. Returns nil if the invite does not exist
  """
  def get_invite(invite_code), do: Repo.get(Invite, invite_code)

  @doc """
  Determines if an invite code is valid
  """
  def invite_code_valid?(invite_code) do
    if get_invite(invite_code) do
      true
    else
      false
    end
  end

  @doc """
  Deletes an invite
  """
  def delete_invite(%Invite{} = invite) do
    Repo.delete(invite)
  end

  @doc """
  Creates an invite.
  """
  def create_invite(%User{} = user, %Catalog.List{} = list, attrs \\ %{}) do
    if list_invites(user, list.id) |> Enum.count() >= @max_invites do
      {:error, "max invites exceeded"}
    else
      %Invite{}
      |> Map.put(:user_id, user.id)
      |> Map.put(:list_id, list.id)
      |> Invite.changeset(attrs)
      |> Repo.insert()
    end
  end

  @doc """
  Returns true if the user is the creator of an invite, false otherwise.
  """
  def invite_creator?(%User{} = user, invite_code) do
    invite =
      get_invite(invite_code)
      |> Repo.preload(:user)

    if invite.user.id == user.id do
      true
    else
      false
    end
  end
end
