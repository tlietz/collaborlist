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
    ~H"""
    <h1>Collaborting on list: <%= @list.title %></h1>

    <span>
      <b>Create New list item:</b>

      <%= Phoenix.View.render(
        CollaborlistWeb.CollabView,
        "live_new_item_form.html",
        assigns
      ) %>
    </span>
    <table>
      <thead>
        <tr>
          <th>Items</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <%= for item <- @list_items do %>
          <tr>
            <td>
              <%= item.content %>
              <br />
              <div>Checked: <%= item.checked %></div>
              <div>Striked: <%= item.striked %></div>
            </td>

            <td>
              <span>
                <!-- The order of @list.id and item.id matter because the url parameters :list_id and :id
            are derived from here-->
                <%= link("Edit",
                  to: Routes.collab_path(@socket, :edit, @list.id, item.id)
                ) %>
              </span>

              <span>
                <button phx-click={Phoenix.LiveView.JS.push("delete", value: %{"item_id" => item.id})}>
                  Delete
                </button>
              </span>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>

    <span>
      <%= link("Add item", to: Routes.collab_path(@socket, :new, @list.id)) %>
    </span>

    <br />

    <span>
      <%= link("Manage Invites",
        to: Routes.invites_path(@socket, :index, @list.id)
      ) %>
    </span>

    <br />

    <span>
      <%= link("Back to Lists", to: Routes.list_path(@socket, :index)) %>
    </span>
    """
  end
end
