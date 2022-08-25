defmodule Collaborlist.Catalog do
  @moduledoc """
  The Catalog context. It deals with lists as a whole without knowing the details of individual items.
  """

  import Ecto.Query, warn: false
  alias Collaborlist.Repo

  alias Collaborlist.Catalog
  alias Collaborlist.Invites.Invite
  alias Collaborlist.Account.User

  @doc """
  Returns the list of lists.

  ## Examples

      iex> list_lists()
      [%Catalog.List{}, ...]

  """
  def list_lists(%User{} = user) do
    user =
      Repo.preload(user, lists: from(list in Catalog.List, order_by: [desc: list.inserted_at]))

    user.lists
  end

  @doc """
  Gets a single list.

  Raises `Ecto.NoResultsError` if the Catalog.List does not exist.

  ## Examples

      iex> get_list!(123)
      %Catalog.List{}

      iex> get_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list!(id), do: Repo.get!(Catalog.List, id)

  def get_list(id), do: Repo.get(Catalog.List, id)

  @doc """
  Creates a list.

  ## Examples

      iex> create_list(user, %{field: value})
      {:ok, %Catalog.List{}}

      iex> create_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(%User{} = user, attrs \\ %{}) do
    %Catalog.List{}
    |> Catalog.List.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:users, [user], required: true)
    |> Repo.insert()
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(list, %{field: new_value})
      {:ok, %Catalog.List{}}

      iex> update_list(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(%Catalog.List{} = list, attrs) do
    list
    |> Catalog.List.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a list.

  ## Examples

      iex> delete_list(list)
      {:ok, %Catalog.List{}}

      iex> delete_list(list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list(%Catalog.List{} = list) do
    Repo.delete(list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list changes.

  ## Examples

      iex> change_list(list)
      %Ecto.Changeset{data: %Catalog.List{}}

  """
  def change_list(%Catalog.List{} = list, attrs \\ %{}) do
    Catalog.List.changeset(list, attrs)
  end

  @doc """
  Returns true if the user is a collaborator on a list, false otherwise.
  """
  def list_collaborator?(%User{} = user, list_id) do
    query =
      from "users_lists",
        select: [:user_id],
        where: [list_id: type(^list_id, :integer), user_id: type(^user.id, :integer)]

    found_user?(Repo.all(query))
  end

  defp found_user?([]), do: false
  defp found_user?(_), do: true

  @doc """
  Adds a user to a list's collaborators
  """
  def add_collaborator(%Invite{} = invite, %User{} = user) do
    invite_with_list =
      invite
      |> Repo.preload(:list)

    add_collaborator(invite_with_list.list, user)
  end

  def add_collaborator(%Catalog.List{} = list, %User{} = user) do
    list_with_collaborators = list |> Repo.preload(:users)

    users = [user | list_with_collaborators.users]

    list_with_collaborators
    |> Catalog.List.changeset_update_collaborators(users)
    |> Repo.update()
  end

  @doc """
  Removes a user as a list's collaborators
  """
  def remove_collaborator(%Catalog.List{} = list, %User{} = user) do
    users = List.delete(list_collaborators(list), user)

    list
    |> Catalog.List.changeset_update_collaborators(users)
    |> Repo.update()
  end

  @doc """
  Returns a list of users that are a list's collaborators
  """
  def list_collaborators(%Catalog.List{} = list) do
    list_with_collaborators =
      list
      |> Repo.preload(:users)

    list_with_collaborators.users
  end
end
