defmodule CollaborlistWeb.PageController do
  use CollaborlistWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
