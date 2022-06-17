defmodule GoogleCerts do
  @moduledoc """
  TODO: documentation

  There is only one client function in this module.

  It does two things:
  1) Verifies the g_csrf token
  2) Validates the user credential with jwks from Google's endpoints

  It returns {:ok, user_id_token} when successfull, and
  {:error, reason} otherwise.

  The `user_id_token` is a map that has the following fields:
  %{
    "aud" => "some stuff",
    "azp" => "code",
    "email" => "",
    "email_verified" => true,
    "exp" => 1655479451,
    "family_name" => "Lietz",
    "given_name" => "Ted",
    "iat" => 1655475851,
    "iss" => "https://accounts.google.com",
    "jti" => "40c49e3b0bd44a02ab646122b9f7420754ff3045",
    "name" => "Ted Lietz",
    "nbf" => 1655475551,
    "picture" => "https://lh3.googleusercontent.com/a-/AOh14GiIQRM-24G9H6Dx6wBc-AltUDYXWz3GLOnLv_VL0A=s96-c",
    "sub" => "113476586568097370311"
  }

  The `sub` field is unique to each user and can be used to identify the authenticated user.
  """

  # Client facing functions
  @spec user_id_token(conn :: any, params :: any) ::
          {:error, any} | {:ok, jwt :: map}
  def user_id_token(conn, params) do
    with {:ok, _token} <- GoogleCerts.CSRF.verify_csrf_token(conn, params),
         {:ok, jwt} <- GoogleCerts.Authentication.verify_id_token(conn, params) do
      {:ok, jwt.fields}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end
end
