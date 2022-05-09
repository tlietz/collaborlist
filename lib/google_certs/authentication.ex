defmodule GoogleCerts.Authentication do
  def account_id(id_token = %JOSE.JWT{}) do
    id_token.fields["sub"]
  end

  # Checks that the g_crsf_token in the POST body and cookie are present and are equal
  def verify_csrf(conn, params) do
    with {true, csrf_token_body} <- csrf_token_in_body?(conn, params),
         {true, csrf_token_cookie} <- csrf_token_in_cookie?(conn, params),
         {true, csrf_token} <- csrf_tokens_equal?(csrf_token_body, csrf_token_cookie) do
      {:ok, csrf_token}
    else
      {false, reason} -> {:error, reason}
    end
  end

  defp csrf_token_in_body?(_conn, params) do
    token = params["g_csrf_token"]

    if token do
      {true, token}
    else
      {false, "CSRF token not found in post body"}
    end
  end

  defp csrf_token_in_cookie?(conn, _params) do
    token = conn.cookies["g_csrf_token"]

    if token do
      {true, token}
    else
      {false, "CSRF token not found in cookies"}
    end
  end

  defp csrf_tokens_equal?(body_token, cookie_token) do
    if body_token == cookie_token do
      {true, body_token}
    else
      {false, "CSRF token in body and cookie do not match"}
    end
  end

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
      {:ok, jwt}
    else
      {false, reason} -> {:error, reason}
    end
  end

  def signature_verified?(jwk = %JOSE.JWK{}, alg, token) do
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

    res = HTTPoison.get!(url)

    keys =
      res.body
      |> Jason.decode!()

    keys
  end
end
