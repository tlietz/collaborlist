defmodule CollaborlistWeb.ListsLive do
  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog

  # TODO: get lists in `mount/3` since that is only run once per liveview, then any updates to the user's lists

  on_mount {CollaborlistWeb.UserAuth, :current_user}

  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]
    lists = Catalog.list_lists(user)

    {:ok, assign(socket, :lists, lists)}
  end

  def handle_event("inc", _, socket) do
    {:noreply, socket}
  end

  def handle_event("dec", _, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    Phoenix.View.render(CollaborlistWeb.ListView, "index.html", assigns)
  end
end
