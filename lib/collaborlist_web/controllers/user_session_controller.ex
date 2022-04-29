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

  # Checks that the g_crsf_token in the POST body and cookie are present and are equal
  def verify_csrf(conn, params) do
    with {:ok, csrf_token_body} <- check_nil(params["g_csrf_token"]),
         {:ok, csrf_token_cookie} <- check_nil(conn.cookies["g_csrf_token"]) do
      if csrf_token_body == csrf_token_cookie do
        {:ok, csrf_token_body}
      else
        {:error, "CSRF token in body and cookie do not match"}
      end
    else
      nil -> {:error, "CSRF token not found in either post body or cookie"}
    end
  end

  defp check_nil(nil), do: nil
  defp check_nil(x), do: {:ok, x}

  def verify_id_token(conn, params) do
    keys = jwk_keys()

    token = params["credential"]

    {:ok, header} =
      token
      |> Joken.peek_header()

    key_id = header["kid"]

    jwk = JOSE.JWK.from_pem(keys[key_id])

    with {true, jwt, _jws} <- verify_signature(jwk, header["alg"], token),
         {true, _aud} <- aud_match(jwt) do
      {:ok, token}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def verify_signature(jwk, alg, token) do
    # function expects a list of algorithms to whitelist
    JOSE.JWT.verify_strict(jwk, [alg], token)
  end

  def aud_match(jwt = %JOSE.JWT{}) do
    aud = jwt.fields["aud"]

    if aud == "486854246467-4o5dqr6fv5jkbojbhp6flddtfqf8ch8d.apps.googleusercontent.com" do
      {true, aud}
    else
      {:error, "token `aud` field does not match application client ID"}
    end
  end

  def jwk_keys() do
    # url for PEM encoded keys
    url = "https://www.googleapis.com/oauth2/v1/certs"

    %HTTPoison.Response{body: res} = HTTPoison.get!(url)

    keys =
      res
      |> Jason.decode!()

    keys
  end
end
