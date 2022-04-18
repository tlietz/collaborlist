defmodule CollaborlistWeb.UserSessionController do
  use CollaborlistWeb, :controller

  # TODO If a user enters the app through a url pointing to a specific list,
  # TODO let the user login, then check if they have authorization to view the list.
  # TODO If they do, redirect to `referer`. If not, redirect to `lists/` with a flash
  # TODO message saying to make sure they got the correct link/qr code to collab on the list.
  def login(conn, _params) do
    [referer] =
      conn
      |> get_req_header("referer")

    conn
    |> put_flash(:info, "Logged in successfully")
    # this has the `external` tag because the `referer` from `get_req_header` returns a full URL.
    |> redirect(external: referer)
  end
end
