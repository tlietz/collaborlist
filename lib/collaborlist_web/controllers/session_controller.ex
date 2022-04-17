defmodule CollaborlistWeb.SessionController do
  use CollaborlistWeb, :controller

  def login(conn, _params) do
    conn
    |> put_flash(:info, "Logged in successfully")
    |> redirect(to: Routes.list_path(conn, :index))
  end
end
