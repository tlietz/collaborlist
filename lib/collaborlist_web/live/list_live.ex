defmodule CollaborlistWeb.ListLive do
  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog

  on_mount {CollaborlistWeb.UserAuth, :current_user}

  # TODO: Write about design decision to keep track of state seperately between server and client so that all the lists do not have to be queried each time an edit is made.

  # TODO: Write integration tests for client and server staying in sync when doing CRUD operations on lists

  # TODO: Ensure that when a CRUD operation happens on a list item of a list, the list `updated_at` gets updated

  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]
    lists = Catalog.list_lists(user)

    changeset = Catalog.change_list(%Catalog.List{})

    {:ok,
     socket
     |> assign(:lists, lists)
     |> assign(:changeset, changeset)}
  end

  def handle_event("delete", %{"list_id" => id}, socket) do
    list = Catalog.get_list!(id)
    {:ok, _list} = Catalog.delete_list(list)

    lists = socket.assigns.lists
    lists_after_delete = lists |> List.delete_at(Enum.find(lists, fn l -> l.id == id end))

    {:noreply,
     assign(socket,
       lists: lists_after_delete
     )}
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"list" => list_params}, socket) do
    user = socket.assigns[:current_user]

    case Catalog.create_list(user, list_params) do
      {:ok, list} ->
        {:noreply, assign(socket, lists: [list | socket.assigns.lists])}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def render(assigns) do
    Phoenix.View.render(CollaborlistWeb.ListView, "index.html", assigns)
  end
end
