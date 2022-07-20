defmodule CollaborlistWeb.ListController do
  use CollaborlistWeb, :controller

  alias Collaborlist.Catalog
  alias Collaborlist.Catalog.List

  def index(conn, _params) do
    user = conn.assigns[:current_user]

    if user do
      lists = Catalog.list_lists(user)
      render(conn, "index.html", lists: lists)
    else
      render(conn, "index.html", lists: [])
    end
  end

  def new(conn, _params) do
    changeset = Catalog.change_list(%List{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"list" => list_params}) do
    user = conn.assigns[:current_user]

    case Catalog.create_list(user, list_params) do
      {:ok, list} ->
        conn
        |> put_flash(:info, "List created successfully.")
        |> redirect(to: Routes.collab_path(conn, :index, list))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"list_id" => id}) do
    list = Catalog.get_list!(id)
    changeset = Catalog.change_list(list)
    render(conn, "edit.html", list: list, changeset: changeset)
  end

  def update(conn, %{"list_id" => id, "list" => list_params}) do
    list = Catalog.get_list!(id)

    case Catalog.update_list(list, list_params) do
      {:ok, _list} ->
        conn
        |> put_flash(:info, "List updated successfully.")
        |> redirect(to: Routes.list_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", list: list, changeset: changeset)
    end
  end

  def delete(conn, %{"list_id" => id}) do
    list = Catalog.get_list!(id)
    {:ok, _list} = Catalog.delete_list(list)

    conn
    |> put_flash(:info, "List deleted successfully.")
    |> redirect(to: Routes.list_path(conn, :index))
  end
end
