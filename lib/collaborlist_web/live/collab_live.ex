# TODO: find a way to clear the `error_tag` in live_new_item_form.html.heex upon submitting a new list_item
defmodule CollaborlistWeb.CollabLive do
  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog
  alias Collaborlist.List.ListItem
  alias Collaborlist.List

  on_mount {CollaborlistWeb.UserAuth, :current_user}

  def mount(%{"list_id" => list_id}, _session, socket) do
    list = Catalog.get_list!(list_id)
    list_items = List.list_list_items(list_id)

    changeset = List.change_list_item(%ListItem{})

    {:ok,
     socket
     |> assign(:list, list)
     |> assign(:list_items, list_items)
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"list_item" => item_params}, socket) do
    case List.create_list_item(item_params, socket.assigns.list) do
      {:ok, item} ->
        {:noreply, assign(socket, list_items: [item | socket.assigns.list_items])}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def render(assigns) do
    Phoenix.View.render(CollaborlistWeb.CollabView, "index.html", assigns)
  end
end
