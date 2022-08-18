# TODO: find a way to clear the `error_tag` in live_new_item_form.html.heex upon submitting a new list_item
defmodule CollaborlistWeb.CollabLive do
  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog
  alias Collaborlist.List.ListItem
  alias Collaborlist.List

  alias Phoenix.PubSub

  on_mount {CollaborlistWeb.UserAuth, :current_user}

  def mount(%{"list_id" => list_id}, _session, socket) do
    PubSub.subscribe(Collaborlist.PubSub, list_id)

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
    current_list = socket.assigns.list

    case List.create_list_item(item_params, current_list) do
      {:ok, item} ->
        new_state = assign(socket, list_items: [item | socket.assigns.list_items])
        CollaborlistWeb.Endpoint.broadcast_from(self(), topic(socket), "save", new_state.assigns)
        {:noreply, new_state}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp topic(socket) do
    Integer.to_string(socket.assigns.list.id)
  end

  def handle_info(msg, socket) do
    {:noreply, assign(socket, list_items: msg.payload.list_items)}
  end

  def render(assigns) do
    Phoenix.View.render(CollaborlistWeb.CollabView, "index.html", assigns)
  end
end
