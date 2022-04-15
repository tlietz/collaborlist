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

  def create(conn, %{"list_id" => list_id, "list_item" => item}) do
    case List.create_list_item(item, Catalog.get_list!(list_id)) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item added successfully.")
        |> redirect(to: Routes.collab_path(conn, :index, list_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
