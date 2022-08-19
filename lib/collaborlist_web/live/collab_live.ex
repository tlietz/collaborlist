# TODO: find a way to clear the `error_tag` in live_new_item_form.html.heex upon submitting a new list_item
defmodule CollaborlistWeb.CollabLive do
  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog
  alias Collaborlist.List.ListItem

  alias Phoenix.PubSub

  on_mount {CollaborlistWeb.UserAuth, :current_user}

  def mount(%{"list_id" => list_id}, _session, socket) do
    PubSub.subscribe(Collaborlist.PubSub, list_id)

    list = Catalog.get_list!(list_id)
    list_items = Collaborlist.List.list_list_items(list_id)

    changeset = Collaborlist.List.change_list_item(%ListItem{})

    {:ok,
     socket
     |> assign(:list, list)
     |> assign(:list_items, list_items)
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("save" = event, %{"list_item" => item_params}, socket) do
    current_list = socket.assigns.list

    case Collaborlist.List.create_list_item(item_params, current_list) do
      {:ok, item} ->
        CollaborlistWeb.Endpoint.broadcast(topic(socket), event, item)

        {:noreply, assign(socket, :changeset, Collaborlist.List.change_list_item(%ListItem{}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("delete" = event, %{"item_id" => item_id}, socket) do
    item = Collaborlist.List.get_list_item!(item_id)
    {:ok, _list_item} = Collaborlist.List.delete_list_item(item)

    CollaborlistWeb.Endpoint.broadcast(topic(socket), event, item)

    {:noreply, socket}
  end

  def handle_info(msg = %{event: "save"}, socket) do
    item = msg.payload

    {:noreply, client_add_list_item(socket, item)}
  end

  def handle_info(msg = %{event: "delete"}, socket) do
    item = msg.payload

    {:noreply, client_delete_list_item(socket, item)}
  end

  defp client_add_list_item(socket, item) do
    assign(socket, list_items: [item | socket.assigns.list_items])
  end

  defp client_delete_list_item(socket, item) do
    items = socket.assigns.list_items

    items_after_delete =
      items
      |> List.delete_at(Enum.find_index(items, fn l -> l.id == item.id end))

    assign(socket, list_items: items_after_delete)
  end

  defp topic(socket) do
    Integer.to_string(socket.assigns.list.id)
  end

  def render(assigns) do
    Phoenix.View.render(CollaborlistWeb.CollabView, "index.html", assigns)
  end
end
