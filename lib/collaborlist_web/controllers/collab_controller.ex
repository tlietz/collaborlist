defmodule CollaborlistWeb.CollabController do
  use CollaborlistWeb, :controller

  alias Collaborlist.Catalog
  alias Collaborlist.List.ListItem
  alias Collaborlist.List

  def index(conn, %{"list_id" => list_id}) do
    list = Catalog.get_list!(list_id)
    list_items = List.list_list_items(list_id)
    render(conn, "index.html", list_items: list_items, list: list)
  end

  # Create a new list item
  def new(conn, %{"list_id" => list_id}) do
    list = Catalog.get_list!(list_id)
    changeset = List.change_list_item(%ListItem{})
    render(conn, "new.html", changeset: changeset, list: list)
  end

  def create(conn, %{"list_id" => list_id, "list_item" => item_params}) do
    case List.create_list_item(item_params, Catalog.get_list!(list_id)) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item added successfully.")
        |> redirect(to: Routes.collab_path(conn, :index, list_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"list_id" => list_id, "id" => item_id}) do
    list = Catalog.get_list!(list_id)
    item = List.get_list_item!(item_id)
    changeset = List.change_list_item(item)
    render(conn, "edit.html", list: list, list_item: item, changeset: changeset)
  end

  def update(conn, %{"list_id" => list_id, "id" => item_id, "list_item" => item_params}) do
    list = Catalog.get_list!(list_id)
    list_item = List.get_list_item!(item_id)

    case List.update_list_item(list_item, item_params) do
      {:ok, _list_item} ->
        conn
        |> put_flash(:info, "List updated successfully.")
        |> redirect(to: Routes.collab_path(conn, :index, list_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", list: list, changeset: changeset)
    end
  end

  def delete(conn, %{"list_id" => list_id, "id" => item_id}) do
    list_item = List.get_list_item!(item_id)
    {:ok, _list_item} = List.delete_list_item(list_item)

    conn
    |> put_flash(:info, "Item deleted successfully.")
    |> redirect(to: Routes.collab_path(conn, :index, list_id))
  end
end
