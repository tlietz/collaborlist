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
        socket
        |> IO.inspect(label: "BEFORE")

        {:noreply, assign(socket, :lists, [list | socket.assigns.lists])}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)}
    end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Listing Lists</h1>

    <span>
      <b>Create New List:</b>

      <.form let={f} for={@changeset} phx-change="validate" phx-submit="save">
        <%= if @changeset.action do %>
          <div class="alert alert-danger">
            <p>
              Oops, something went wrong!
            </p>
          </div>
        <% end %>

        <%= label(f, :title) %>
        <%= text_input(f, :title) %>
        <%= error_tag(f, :title) %>

        <button type="submit">
          Save
        </button>
      </.form>
    </span>
    <table>
      <thead>
        <tr>
          <th>List</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <%= for list <- @lists do %>
          <tr>
            <td><%= list.title %></td>

            <td>
              <span><%= link("Collab", to: Routes.collab_path(@socket, :index, list.id)) %></span>
              <br />
              <span>
                <%= link("Change List Name", to: Routes.list_path(@socket, :edit, list.id)) %>
              </span>
              <br />
              <span>
                <%= link("Delete",
                  to: Routes.list_path(@socket, :delete, list.id),
                  method: :delete,
                  data: [confirm: "Are you sure?"]
                ) %>
              </span>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
