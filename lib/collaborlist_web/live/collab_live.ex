defmodule CollaborlistWeb.CollabLive do
  # TODO: make the invite manager a liveview modal that automatically copies the latest invite to clipboard

  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog
  alias Collaborlist.List.ListItem

  alias Phoenix.PubSub
  alias Phoenix.LiveView.JS

  @edit_timeout_seconds 1

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
     |> assign(:changeset, changeset)
     |> assign(:edit_ids, MapSet.new())}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, _params) do
    assign(socket, show_modal: false)
  end

  def apply_action(%{assigns: %{show_modal: _}} = socket, :invite_modal, _params) do
    assign(socket, show_modal: true)
  end

  def apply_action(socket, _live_action, _params) do
    push_patch(socket,
      to: Routes.collab_path(socket, :index, socket.assigns.list.id),
      replace: true
    )
  end

  def handle_event("open_invite_modal", _, socket) do
    {:noreply,
     push_patch(
       socket,
       to: Routes.collab_path(socket, :invite_modal, socket.assigns.list.id),
       replace: true
     )}
  end

  def handle_event("start_edit", %{"item_id" => item_id}, socket) do
    {:noreply, socket |> start_editing(item_id |> maybe_int_to_string())}
  end

  def handle_event("nothing", _, socket) do
    {:noreply, socket}
  end

  def handle_event("status_update", %{"item_id" => item_id}, socket) do
    list_item = Collaborlist.List.get_list_item!(item_id)
    {:ok, updated_item} = Collaborlist.List.toggle_list_item_status(list_item)

    CollaborlistWeb.Endpoint.broadcast(topic(socket), "item_update", updated_item)

    {:noreply, socket}
  end

  def handle_event(
        "item_update" = event,
        %{"item-id" => item_id, "content" => updated_content},
        socket
      ) do
    {:ok, updated_item} =
      Collaborlist.List.update_list_item(Collaborlist.List.get_list_item!(item_id), %{
        "content" => updated_content
      })

    CollaborlistWeb.Endpoint.broadcast(topic(socket), event, updated_item)

    {:noreply, socket |> start_editing(item_id |> maybe_int_to_string())}
  end

  def handle_event(
        "list_update" = event,
        %{"list-id" => list_id, "title" => updated_title},
        socket
      ) do
    {:ok, updated_list} =
      Catalog.update_list(Catalog.get_list!(list_id), %{"title" => updated_title})

    CollaborlistWeb.Endpoint.broadcast(topic(socket), event, updated_list)

    {:noreply, socket}
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("save" = event, _, socket) do
    current_list = socket.assigns.list

    case Collaborlist.List.create_list_item(%{"content" => "item"}, current_list) do
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

  def handle_event("show_modal", _, socket) do
    socket
    |> show_invite_modal()
  end

  defp show_invite_modal(socket) do
    {:noreply, socket}
  end

  def handle_info(
        {CollaborlistWeb.Live.InviteModal, :button_clicked, %{action: "exit_modal"}},
        socket
      ) do
    {:noreply,
     push_patch(socket,
       to: Routes.collab_path(socket, :index, socket.assigns.list.id),
       replace: true
     )}
  end

  def handle_info(msg = %{event: "start_edit"}, socket) do
    item_id = msg.payload

    edited = socket.assigns.edit_ids
    {:noreply, socket |> assign(edit_ids: edited |> MapSet.put(item_id))}
  end

  def handle_info(msg = %{event: "broadcast_stop_edit"}, socket) do
    item_id = msg.payload
    CollaborlistWeb.Endpoint.broadcast_from(self(), topic(socket), "stop_edit", item_id)

    {:noreply, socket}
  end

  def handle_info(msg = %{event: "stop_edit"}, socket) do
    item_id = msg.payload

    edited = socket.assigns.edit_ids
    {:noreply, socket |> assign(edit_ids: edited |> MapSet.delete(item_id))}
  end

  def handle_info(msg = %{event: "item_update"}, socket) do
    updated_item = msg.payload

    {:noreply, client_item_update(socket, updated_item)}
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

  defp client_item_update(socket, updated_item) do
    assign(socket,
      list_items:
        Enum.map(socket.assigns.list_items, fn item ->
          if item.id == updated_item.id, do: updated_item, else: item
        end)
    )
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

  defp maybe_set_editing_class(edit_ids, item_id) do
    if MapSet.member?(edit_ids, item_id |> maybe_int_to_string()) do
      "edited"
    else
      ""
    end
  end

  defp maybe_int_to_string(item_id) when is_integer(item_id) do
    Integer.to_string(item_id)
  end

  defp maybe_int_to_string(item_id) do
    item_id
  end

  defp start_editing(socket, item_id) do
    CollaborlistWeb.Endpoint.broadcast_from(self(), topic(socket), "start_edit", item_id)
    schedule_stop_editing(socket, item_id)

    socket
  end

  defp schedule_stop_editing(_socket, item_id) do
    msg = %{event: "broadcast_stop_edit", payload: item_id}
    Process.send_after(self(), msg, 1000 * @edit_timeout_seconds)
  end

  defp stop_editing(socket, item_id) do
    CollaborlistWeb.Endpoint.broadcast_from(self(), topic(socket), "stop_edit", item_id)
  end

  def render(assigns) do
    ~H"""
    <h1>
      <form phx-change="list_update" phx-submit="nothing" onsubmit="nothing" class="list-form">
        <input
          type="text"
          style="border-radius: 2rem; font-weight: bold; font-size: 2rem; border-width: 0.2rem; border-color: grey; "
          id={"list-" <> Integer.to_string(@list.id)}
          name="title"
          value={@list.title}
          spellcheck="false"
          autocomplete="off"
          style=""
        />
        <input type="hidden" name="list-id" value={@list.id} />
      </form>
    </h1>

    <span>
      <button phx-click="save" style="display:inline-block">
        + Add List Item
      </button>

      <button phx-click="open_invite_modal" style="display:inline-block; float:right;">
        Invite
      </button>

      <%= if @show_modal do %>
        <.live_component
          module={CollaborlistWeb.Live.InviteModal}
          id="invites"
          title="Invite Links"
          body=""
          right_button="Create Invite"
          right_button_action="create_invite"
          left_button="Exit"
          left_button_action="exit_modal"
          list_id={@list.id}
          user_id={@current_user.id}
        />
      <% end %>
    </span>
    <table>
      <thead>
        <tr>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <%= for item <- @list_items do %>
          <tr class={maybe_set_editing_class(@edit_ids, item.id)}>
            <td>
              <div
                class={"status-button " <> " status-" <> Atom.to_string(item.status)}
                phx-click={JS.push("status_update", value: %{"item_id" => item.id})}
              >
              </div>
            </td>
            <td>
              <form phx-change="item_update" phx-submit="nothing" onsubmit="nothing" class="list-form">
                <input
                  class="collab-list-item"
                  type="text"
                  id={"item-" <> Integer.to_string(item.id)}
                  name="content"
                  value={item.content}
                  spellcheck="false"
                  autocomplete="off"
                  style="margin-bottom:0px;"
                  phx-click={JS.push("start_edit", value: %{"item_id" => item.id})}
                />
                <input type="hidden" name="item-id" value={item.id} />
              </form>
            </td>
            <td>
              <span style="padding-left: 2rem;">
                <div
                  style="display: inline-block;"
                  class="gg-trash"
                  phx-click={JS.push("delete", value: %{"item_id" => item.id})}
                >
                </div>
              </span>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
