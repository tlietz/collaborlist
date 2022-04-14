defmodule CollaborlistWeb.CollabController do
  use CollaborlistWeb, :controller

  alias Collaborlist.Catalog

  def index(conn, %{"list_id" => id}) do
    list = Catalog.get_list!(id)
    render(conn, "index.html", list: list)
  end
end
