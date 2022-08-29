defmodule CollaborlistWeb.Live.InviteModal do
  use CollaborlistWeb, :live_component

  alias Collaborlist.Invites
  alias Collaborlist.Account
  alias Collaborlist.Catalog

  alias Phoenix.LiveView.JS

  @defaults %{
    left_button: "Cancel",
    left_button_action: nil,
    left_button_param: nil,
    right_button: "OK",
    right_button_action: nil,
    right_button_param: nil,
    list_id: nil,
    user_id: nil,
    error_message: nil
  }

  def mount(socket) do
    {:ok, socket |> assign(open: false)}
  end

  def update(%{id: _id} = assigns, socket) do
    user = Account.get_user(assigns.user_id)
    list = Catalog.get_list(assigns.list_id)
    invites = Invites.list_invites(user, list.id)

    {:ok,
     socket
     |> assign(Map.merge(@defaults, assigns))
     |> assign(invites: invites)
     |> assign(current_user: user)
     |> assign(list: list)
     |> maybe_create_invite()}
  end

  defp maybe_create_invite(socket) do
    if socket.assigns.invites == [] do
      {:ok, invite} = Invites.create_invite(socket.assigns[:current_user], socket.assigns.list)

      socket
      |> assign(invites: [invite])
    else
      socket
    end
  end

  def render(assigns) do
    ~H"""
    <div id={"modal-" <> @id}>
      <!-- Modal Background -->
      <div class="modal-container">
        <div class="modal-inner-container">
          <div class="modal-card">
            <div class="modal-inner-card">
              <!-- Title -->
              <%= if @title != nil do %>
                <div class="modal-title">
                  <%= @title %>
                </div>
              <% end %>
              <!-- Body -->
              <%= if @body != nil do %>
                <div class="modal-body">
                  <%= @body %>
                </div>
              <% end %>

              <table>
                <tbody>
                  <%= for invite <- @invites do %>
                    <tr>
                      <td>
                        <%= CollaborlistWeb.InvitesView.invite_link(invite) %>
                      </td>
                      <td>
                        <span>
                          <button
                            phx-click={
                              JS.push("delete", value: %{"invite_code" => invite.invite_code})
                            }
                            phx-target={"#modal-" <> @id}
                          >
                            Delete
                          </button>
                        </span>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
              <!-- error message -->
              <%= if @error_message != nil do %>
                <div class="alert-danger">
                  <%= @error_message %>
                </div>
              <% end %>
              <!-- Buttons -->
              <div class="modal-buttons">
                <!-- Left Button -->
                <button
                  class="left-button"
                  type="button"
                  phx-click="left-button-click"
                  phx-target={"#modal-" <> @id}
                >
                  <div>
                    <%= @left_button %>
                  </div>
                </button>
                <!-- Right Button -->
                <button
                  class="right-button"
                  type="button"
                  phx-click="right-button-click"
                  phx-target={"#modal-" <> @id}
                >
                  <div>
                    <%= @right_button %>
                  </div>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("delete", %{"invite_code" => invite_code}, socket) do
    invite = Invites.get_invite!(invite_code)

    if Invites.invite_creator?(socket.assigns.current_user, invite.invite_code) do
      {:ok, _invite} = Invites.delete_invite(invite)

      invites = socket.assigns.invites

      invites_after_delete =
        invites
        |> List.delete_at(Enum.find_index(invites, fn i -> i.invite_code == invite_code end))

      {:noreply,
       assign(socket,
         invites: invites_after_delete
       )}
    else
      {:noreply, assign(socket, error_message: "you can't do that")}
    end
  end

  def handle_event(
        "right-button-click",
        _params,
        socket
      ) do
    user = socket.assigns[:current_user]
    list_id = socket.assigns.list.id
    list = Catalog.get_list!(list_id)

    case Invites.create_invite(user, list) do
      {:ok, invite} ->
        invites = [invite | socket.assigns.invites]

        {:noreply,
         socket
         |> assign(invites: invites)
         |> assign(error_message: nil)}

      {:error, _} ->
        {:noreply,
         socket
         |> assign(error_message: "Maximum number of invites created")}
    end
  end

  def handle_event(
        "left-button-click",
        _params,
        %{
          assigns: %{
            left_button_action: left_button_action,
            left_button_param: left_button_param
          }
        } = socket
      ) do
    send(
      self(),
      {__MODULE__, :button_clicked, %{action: left_button_action, param: left_button_param}}
    )

    {:noreply, socket}
  end
end
