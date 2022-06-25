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
    "family_name" => "Last name",
    "given_name" => "First name",
    "iat" => 1655475851,
    "iss" => "https://accounts.google.com",
    "jti" => "40c49e3b0bd44a02ab646122b9f7420754ff3045",
    "name" => "Ted Lietz",
    "nbf" => 1655475551,
    "picture" => "link to picture",
    "sub" => "unique user id"
  }

  The `sub` field is unique to each user and can be used to identify the authenticated user.
  """

  # Client facing functions

  @doc """
  Returns an `id_token` of the user that was authenticated.
  An `id_token` is what Google calls their JWT.
  """
  @spec user_id_token(conn :: any, params :: any) ::
          {:error, any} | {:ok, id_token :: map}
  def user_id_token(conn, params) do
    with {:ok, _token} <- GoogleCerts.CSRF.verify_csrf_token(conn, params),
         {:ok, jwt} <- GoogleCerts.Authentication.verify_id_token(conn, params) do
      {:ok, jwt.fields}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  def uid(id_token) do
  end
end
