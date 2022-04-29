defmodule CollaborlistWeb.UserSessionController do
  use CollaborlistWeb, :controller

  def create(conn, params) do
    with {:ok, _token} <- verify_csrf(conn, params),
         {:ok, account_id} <- verify_id_token(conn, params) do
      [referer] =
        conn
        |> get_req_header("referer")

      conn
      |> put_flash(:info, "signed in with google successfully, your account id is #{account_id}")
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

  def verify_id_token(_conn, params) do
    keys = jwk_keys()

    token = params["credential"]

    {:ok, header} =
      token
      |> Joken.peek_header()

    key_id = header["kid"]

    jwk = JOSE.JWK.from_pem(keys[key_id])

    with {true, jwt, _jws} <- signature_verified?(jwk, header["alg"], token),
         {true, _aud} <- aud_valid?(jwt),
         {true, _iss} <- iss_valid?(jwt),
         {true, _iat, _exp} <- not_expired?(jwt) do
      {:ok, jwt.fields["sub"]}
    else
      {false, reason} -> {:error, reason}
    end
  end

  def signature_verified?(jwk, alg, token) do
    # function expects a list of algorithms to whitelist
    case JOSE.JWT.verify_strict(jwk, [alg], token) do
      {true, jwt, jws} -> {true, jwt, jws}
      {:error, _} -> {false, "signature verification failed"}
    end
  end

  def aud_valid?(jwt = %JOSE.JWT{}) do
    aud = jwt.fields["aud"]

    if aud == "486854246467-4o5dqr6fv5jkbojbhp6flddtfqf8ch8d.apps.googleusercontent.com" do
      {true, aud}
    else
      {false, "token `aud` field does not match application client ID"}
    end
  end

  def iss_valid?(jwt = %JOSE.JWT{}) do
    iss = jwt.fields["iss"]

    if iss == "accounts.google.com" or iss == "https://accounts.google.com" do
      {true, iss}
    else
      {false, "token `iss` field is invalid"}
    end
  end

  def not_expired?(jwt = %JOSE.JWT{}) do
    expire_time = jwt.fields["exp"]
    issued_at = jwt.fields["iat"]

    if issued_at < expire_time do
      {true, issued_at, expire_time}
    else
      {false, "token is expired"}
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
