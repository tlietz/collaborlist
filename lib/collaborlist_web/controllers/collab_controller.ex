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

  def create(conn, %{"list" => list_params}) do
    case Catalog.create_list(list_params) do
      {:ok, list} ->
        conn
        |> put_flash(:info, "List created successfully.")
        |> redirect(to: Routes.collab_path(conn, :index, list))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
