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
    user_id: nil
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
     |> assign(list: list)}
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
                          <button phx-click={
                            JS.push("delete", value: %{"invite_code" => invite.invite_code})
                          }>
                            Delete
                          </button>
                        </span>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
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
        {:noreply, socket |> assign(invites: invites)}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "error occured while trying to create invite link")}
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