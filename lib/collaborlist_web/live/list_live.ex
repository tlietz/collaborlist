defmodule CollaborlistWeb.ListLive do
  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog

  on_mount {CollaborlistWeb.UserAuth, :current_user}

  # TODO: Write about design decision to keep track of state seperately between server and client so that all the lists do not have to be queried each time an edit is made.

  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]
    lists = Catalog.list_lists(user)

    changeset = Catalog.change_list(%Catalog.List{})

    {:ok,
     socket
     |> assign(:lists, lists)
     |> assign(:changeset, changeset)}
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
        {:noreply,
         socket
         |> assign(:changeset, changeset)}
    end
  end

  def render(assigns) do
    Phoenix.View.render(CollaborlistWeb.ListView, "index.html", assigns)
  end
end
