defmodule Collaborlist.List do
  @moduledoc """
  The List context.
  """

  import Ecto.Query, warn: false
  alias Collaborlist.Repo

  alias Collaborlist.List.ListItem
  alias Collaborlist.Catalog

  @doc """
  Returns the list of list_items that belong to a list.

  """
  def list_list_items(list_id) do
    Repo.all(from li in ListItem, where: li.list_id == ^list_id, order_by: [desc: li.inserted_at])
  end

  @doc """
  Gets a single list_item.

  Raises `Ecto.NoResultsError` if the List item does not exist.

  ## Examples

      iex> get_list_item!(123)
      %ListItem{}

      iex> get_list_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list_item!(id), do: Repo.get!(ListItem, id)

  @doc """
  Creates a list_item and adds it to a list.
  """
  def create_list_item(attrs \\ %{}, %Catalog.List{} = list) do
    %ListItem{}
    |> Map.put(:list_id, list.id)
    |> ListItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a list_item.

  ## Examples

      iex> update_list_item(list_item, %{field: new_value})
      {:ok, %ListItem{}}

      iex> update_list_item(list_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list_item(%ListItem{} = list_item, attrs) do
    list_item
    |> ListItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a list_item.

  ## Examples

      iex> delete_list_item(list_item)
      {:ok, %ListItem{}}

      iex> delete_list_item(list_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list_item(%ListItem{} = list_item) do
    Repo.delete(list_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list_item changes.

  ## Examples

      iex> change_list_item(list_item)
      %Ecto.Changeset{data: %ListItem{}}

  """
  def change_list_item(%ListItem{} = list_item, attrs \\ %{}) do
    ListItem.changeset(list_item, attrs)
  end

  @doc """
  Sets a list_item's status based on its current status and the `set_status` depicted by the arrows:

  "Current Status" (set_status) ->  "New Status"
  :checked (:checked) -> :none
  :striked (:striked) -> :none
  :none    (:none)    -> :none
  :none               -> `set_status`
  :checked (:striked) -> :striked
  :striked (:checked) -> :checked

  """
  def toggle_list_item_status(%ListItem{} = list_item, set_status) do
    if list_item.status == set_status do
      set_list_item_status(list_item, :none)
    else
      set_list_item_status(list_item, set_status)
    end
  end

  @doc """
  Sets a list_item's status to `set_status`
  """
  def set_list_item_status(%ListItem{} = list_item, set_status) do
    unless list_item.status == set_status do
      list_item
      |> ListItem.changeset(%{status: set_status})
      |> Repo.update()
    end
  end
end
