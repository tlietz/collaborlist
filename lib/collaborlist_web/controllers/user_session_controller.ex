defmodule CollaborlistWeb.UserSessionController do
  use CollaborlistWeb, :controller

  def create(conn, params) do
    case GoogleCerts.user_id_token(conn, params) do
      {:ok, id_token} ->
        [referer] =
          conn
          |> get_req_header("referer")

        conn
        |> put_flash(
          :info,
          "signed in with google successfully, user id is #{id_token["sub"]}"
        )
        # this has the `external` tag because the `referer` from `get_req_header` returns a full URL.
        |> redirect(external: referer)

      {:error, reason} ->
        conn
        |> put_flash(:error, "Sign in failed because #{reason}")
        |> redirect(to: Routes.list_path(conn, :index))
    end
  end
end
