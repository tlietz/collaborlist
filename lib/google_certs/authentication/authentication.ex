defmodule GoogleCerts.Authentication do
  def account_id(id_token = %JOSE.JWT{}) do
    id_token.fields["sub"]
  end

  # Checks that the id token is valid
  @spec verify_id_token(any, nil | maybe_improper_list | map) ::
          {:error, any} | {:ok, JOSE.JWT.t()}
  def verify_id_token(_conn, params) do
    token = params["credential"]

    {:ok, header} =
      token
      |> Joken.peek_header()

    key_id = header["kid"]

    jwk = GoogleCerts.jwk(key_id)

    with {true, jwt, _jws} <- signature_verified?(jwk, header["alg"], token),
         {true, _aud} <- aud_valid?(jwt),
         {true, _iss} <- iss_valid?(jwt),
         {true, _iat, _exp} <- not_expired?(jwt) do
      {:ok, jwt}
    else
      {false, reason} -> {:error, reason}
    end
  end

  defp signature_verified?(jwk, alg, token) do
    # verify_strict/3 expects a list of algorithms to whitelist
    case JOSE.JWT.verify_strict(jwk, [alg], token) do
      {true, jwt, jws} -> {true, jwt, jws}
      {:error, _} -> {false, "signature verification failed"}
    end
  end

  defp aud_valid?(jwt = %JOSE.JWT{}) do
    aud = jwt.fields["aud"]

    if aud == "486854246467-4o5dqr6fv5jkbojbhp6flddtfqf8ch8d.apps.googleusercontent.com" do
      {true, aud}
    else
      {false, "token `aud` field does not match application client ID"}
    end
  end

  defp iss_valid?(jwt = %JOSE.JWT{}) do
    iss = jwt.fields["iss"]

    if iss == "accounts.google.com" or iss == "https://accounts.google.com" do
      {true, iss}
    else
      {false, "token `iss` field is invalid"}
    end
  end

  defp not_expired?(jwt = %JOSE.JWT{}) do
    expire_time = jwt.fields["exp"]
    issued_at = jwt.fields["iat"]

    if issued_at < expire_time do
      {true, issued_at, expire_time}
    else
      {false, "token is expired"}
    end
  end

  defp jwk_keys() do
    # url for PEM encoded keys
    url = "https://www.googleapis.com/oauth2/v1/certs"

    res = HTTPoison.get!(url)

    keys =
      res.body
      |> Jason.decode!()

    keys
  end
end
