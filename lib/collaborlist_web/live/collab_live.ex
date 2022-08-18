defmodule CollaborlistWeb.CollabLive do
  use CollaborlistWeb, :live_view

  alias Collaborlist.Catalog
  alias Collaborlist.List.ListItem
  alias Collaborlist.List

  on_mount {CollaborlistWeb.UserAuth, :current_user}

  def mount(%{"list_id" => list_id}, _session, socket) do
    list = Catalog.get_list!(list_id)
    list_items = List.list_list_items(list_id)

    changeset = List.change_list_item(%ListItem{})

    {:ok,
     socket
     |> assign(:list, list)
     |> assign(:list_items, list_items)
     |> assign(:changeset, changeset)}
  end

  def render(assigns) do
    Phoenix.View.render(CollaborlistWeb.CollabView, "index.html", assigns)
  end
end
