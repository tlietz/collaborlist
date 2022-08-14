defmodule CollaborlistWeb.ListLive do
  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog

  on_mount {CollaborlistWeb.UserAuth, :current_user}

  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]
    lists = Catalog.list_lists(user)

    changeset = Catalog.change_list(%Catalog.List{})

    {:ok,
     socket
     |> assign(:lists, lists)
     |> assign(:changeset, changeset)}
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
