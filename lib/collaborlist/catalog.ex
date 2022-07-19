defmodule Collaborlist.Catalog do
  @moduledoc """
  The Catalog context. It deals with lists as a whole without knowing the details of individual items.
  """

  import Ecto.Query, warn: false
  alias Collaborlist.Repo

  alias Collaborlist.Catalog.List
  alias Collaborlist.Account.User

  @doc """
  Returns the list of lists.

  ## Examples

      iex> list_lists()
      [%List{}, ...]

  """
  def list_lists do
    Repo.all(List)
  end

  @doc """
  Gets a single list.

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list!(123)
      %List{}

      iex> get_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list!(id), do: Repo.get!(List, id)

  @doc """
  Creates a list.

  ## Examples

      iex> create_list(user, %{field: value})
      {:ok, %List{}}

      iex> create_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(%User{} = user, attrs \\ %{}) do
    %List{}
    |> List.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:users, [user], required: true)
    |> Repo.insert()
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(list, %{field: new_value})
      {:ok, %List{}}

      iex> update_list(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a list.

  ## Examples

      iex> delete_list(list)
      {:ok, %List{}}

      iex> delete_list(list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list(%List{} = list) do
    Repo.delete(list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list changes.

  ## Examples

      iex> change_list(list)
      %Ecto.Changeset{data: %List{}}

  """
  def change_list(%List{} = list, attrs \\ %{}) do
    List.changeset(list, attrs)
  end

  @doc """
  Returns true if the user is a collaborator on a list, false otherwise.
  """
  # TODO write tests for this function
  def list_collaborator?(list_id, %User{} = user) do
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
  def add_collaborator(list_id, %User{} = user) do
  end

  @doc """
  Removes a user from a list's collaborators
  """
  def remove_collaborator(list_id, %User{} = user) do
  end

  @doc """
  Returns the list of a list's collaborators
  """
  def list_collaborators(list_id) do
  end
end
