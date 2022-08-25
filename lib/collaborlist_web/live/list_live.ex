defmodule CollaborlistWeb.ListLive do
  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog

  alias Phoenix.LiveView.JS

  on_mount {CollaborlistWeb.UserAuth, :current_user}

  # TODO: Write about design decision to keep track of state seperately between server and client so that all the lists do not have to be queried each time an edit is made.

  # TODO: Write integration tests for client and server staying in sync when doing CRUD operations on lists

  # TODO: Ensure that when a CRUD operation happens on a list item of a list, the list `updated_at` gets updated

  # TODO: Find a way to render list and collab forms as liveviews so that they do not need to rely on the ListView and CollabView

  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]
    lists = Catalog.list_lists(user)

    changeset = Catalog.change_list(%Catalog.List{})

    {:ok,
     socket
     |> assign(:lists, lists)
     |> assign(:changeset, changeset)}
  end

  def handle_event("update", %{"id" => list_id, "title" => updated_title}, socket) do
    case Catalog.update_list(Catalog.get_list(list_id), %{"title" => updated_title}) do
      {:ok, updated_list} ->
        lists = socket.assigns.lists

        {:noreply,
         assign(
           socket,
           :lists,
           Enum.map(lists, fn list ->
             if list.id == updated_list.id, do: updated_list, else: list
           end)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"list" => list_params}, socket) do
    user = socket.assigns[:current_user]

    case Catalog.create_list(user, list_params) do
      {:ok, list} ->
        {:noreply,
         socket
         |> assign(lists: [list | socket.assigns.lists])
         |> assign(:changeset, Catalog.change_list(%Catalog.List{}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("delete", %{"list_id" => id}, socket) do
    list = Catalog.get_list!(id)
    {:ok, _list} = Catalog.delete_list(list)

    lists = socket.assigns.lists
    lists_after_delete = lists |> List.delete_at(Enum.find_index(lists, fn l -> l.id == id end))

    {:noreply,
     assign(socket,
       lists: lists_after_delete
     )}
  end

  def render(assigns) do
    ~H"""
    <h1>Listing Lists</h1>

    <span>
      <button phx-click={JS.toggle(to: "#new")}>
        Create New List
      </button>

      <div style="display:none" id="new">
        <%= Phoenix.View.render(
          CollaborlistWeb.ListView,
          "live_form.html",
          assigns
        ) %>
      </div>
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
            <td>
              <form phx-change="update">
                <input
                  type="text"
                  id={"list-" <> Integer.to_string(list.id)}
                  name="title"
                  value={list.title}
                  spellcheck="false"
                  autocomplete="off"
                />
                <input type="hidden" name="id" value={list.id} />
              </form>
            </td>
            <td>
              <span>
                <%= live_redirect("Collab", to: Routes.collab_path(@socket, :index, list.id)) %>
              </span>
              <br />
              <span>
                <%= link("Change List Name", to: Routes.list_path(@socket, :edit, list.id)) %>
              </span>
              <br />
              <span>
                <button
                  phx-click={JS.push("delete", value: %{"list_id" => list.id})}
                  data-confirm="Are you sure?"
                >
                  Delete
                </button>
              </span>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
