defmodule CollaborlistWeb.ListsLive do
  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :val, 0)}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end

  def render(assigns) do
    user = assigns[:current_user]

    if user do
      lists = Catalog.list_lists(user)
      Phoenix.View.render(CollaborlistWeb.ListView, "index.html", lists: lists)
    else
      Phoenix.View.render(CollaborlistWeb.ListView, "index.html", lists: [])
    end
  end
end
