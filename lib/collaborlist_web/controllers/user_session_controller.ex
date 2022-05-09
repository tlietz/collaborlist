defmodule CollaborlistWeb.UserSessionController do
  use CollaborlistWeb, :controller

  import GoogleCerts.Authentication
  import GoogleCerts.CSRF

  def create(conn, params) do
    with {:ok, _token} <- verify_csrf_token(conn, params),
         {:ok, id_token} <- verify_id_token(conn, params) do
      [referer] =
        conn
        |> get_req_header("referer")

      conn
      |> put_flash(
        :info,
        "signed in with google successfully, your account id is #{account_id(id_token)}"
      )
      # this has the `external` tag because the `referer` from `get_req_header` returns a full URL.
      |> redirect(external: referer)
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.list_path(conn, :index))
    end
  end
end
