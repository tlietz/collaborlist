defmodule CollaborlistWeb.CollabLive do
  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog
  alias Collaborlist.List.ListItem

  alias Phoenix.PubSub
  alias Phoenix.LiveView.JS

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

  def handle_event(
        "list_update" = event,
        %{"list-id" => list_id, "title" => updated_title},
        socket
      ) do
    {:ok, updated_list} =
      Catalog.update_list(Catalog.get_list(list_id), %{"title" => updated_title})

    CollaborlistWeb.Endpoint.broadcast(topic(socket), event, updated_list)

    {:noreply, socket}
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

  def handle_info(msg = %{event: "list_update"}, socket) do
    updated_list = msg.payload

    {:noreply, client_list_update(socket, updated_list)}
  end

  def handle_info(msg = %{event: "save"}, socket) do
    item = msg.payload

    {:noreply, client_add_list_item(socket, item)}
  end

  def handle_info(msg = %{event: "delete"}, socket) do
    item = msg.payload

    {:noreply, client_delete_list_item(socket, item)}
  end

  defp client_list_update(socket, updated_list) do
    assign(socket, list: updated_list)
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
    <h1>
      <form phx-change="list_update">
        <input
          class="collab-list-title"
          type="text"
          id={"list-" <> Integer.to_string(@list.id)}
          name="title"
          value={@list.title}
          spellcheck="false"
          autocomplete="off"
        />
        <input type="hidden" name="list-id" value={@list.id} />
      </form>
    </h1>

    <span>
      <button phx-click={JS.toggle(to: "#new")}>
        Create New List Item
      </button>

      <div style="display:none" id="new">
        <%= Phoenix.View.render(
          CollaborlistWeb.CollabView,
          "live_new_item_form.html",
          assigns
        ) %>
      </div>
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
                <button phx-click={JS.push("delete", value: %{"item_id" => item.id})}>
                  Delete
                </button>
              </span>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>

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
