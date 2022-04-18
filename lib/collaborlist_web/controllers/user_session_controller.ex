defmodule CollaborlistWeb.UserSessionController do
  use CollaborlistWeb, :controller

  # TODO If a user enters the app through a url pointing to a specific list,
  # TODO let the user login, then check if they have authorization to view the list.
  # TODO If they do, redirect to `referer`. If not, redirect to `lists/` with a flash
  # TODO message saying to make sure they got the correct link/qr code to collab on the list.
  def create(conn, params) do
    with {:ok, _token} <- verify_csrf(conn, params),
         {:ok, _token} <- verify_id_token(conn, params) do
      [referer] =
        conn
        |> get_req_header("referer")

      conn
      |> put_flash(:info, "signed in with google successfully")
      # this has the `external` tag because the `referer` from `get_req_header` returns a full URL.
      |> redirect(external: referer)
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.list_path(conn, :index))
    end
  end

  def verify_csrf(conn, params) do
    with {:ok, csrf_token_body} <- check_nil(params["g_csrf_tokenn"]),
         {:ok, csrf_token_cookie} <- check_nil(conn.cookies["g_csrf_token"]) do
      if tokens_equal?(csrf_token_body, csrf_token_cookie) do
        {:ok, csrf_token_body}
      else
        {:error, "potential csrf attack detected, token in body and cookie do not match"}
      end
    else
      nil -> {:error, "g_csrf_token not found in either post body or cookie"}
    end
  end

  defp check_nil(nil), do: nil
  defp check_nil(token), do: {:ok, token}

  defp tokens_equal?(token1, token2) do
    token1 == token2
  end

  def verify_id_token(conn, _params) do
    {:ok, conn}
  end
end
