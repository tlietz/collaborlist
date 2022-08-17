defmodule GoogleCerts do
  @moduledoc """

  The user_id_token client function in this module.

  It does two things:
  1) Verifies the g_csrf token
  2) Validates the user credential with jwks from Google's endpoints

  It returns {:ok, user_id_token} when successfull, and
  {:error, reason} otherwise.

  The `user_id_token` is a map that has the following fields:
  %{
    "aud" => "Your Google app client ID",
    "azp" => "Same as `aud`",
    "email" => "example.email@gmail.com",
    "email_verified" => true,
    "exp" => 1655479451,
    "family_name" => "Last name",
    "given_name" => "First name",
    "hd" => "G suite domain name",
    "iat" => 1655475851,
    "iss" => "https://accounts.google.com",
    "jti" => "40c49e3b0bd44a02ab646122b9f7420754ff3045",
    "name" => "First Last",
    "nbf" => 1655475551,
    "picture" => "link to picture",
    "sub" => "unique user id"
  }

  The `sub` field is unique to each user and can be used to identify the authenticated user.

  The `hd` field is the G suite domain of a user signing in. For example, if the user's email
  is `robbie.rotten@realvillain.com`, then `hd` => "realvillain.com"
  """

  # Client facing functions

  @doc """
  Returns an `id_token` of the user that was authenticated.
  An `id_token` is what Google calls their JWT.

  When the third argument of a g_suite_domain is passed in,
  user_id_token/3 will be invoked.
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

  @doc """
  Goes through verifying the CSRF, but does an extra check that the `id_token` has a claim
  that matched the `g_suite_domain`.
  """
  @spec user_id_token(conn :: any, params :: any, g_suite_domain :: String.t()) ::
          {:error, any} | {:ok, id_token :: map}
  def user_id_token(conn, params, g_suite_domain) do
    case user_id_token(conn, params) do
      {:ok, id_token} ->
        if g_suite_domain == id_token["hd"] do
          {:ok, id_token}
        else
          {:error, "G suite domain of user is unauthorized"}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec uid(id_token :: map) :: String.t()
  def uid(id_token) do
    id_token["sub"]
  end

  @spec email(id_token :: map) :: String.t()
  def email(id_token) do
    id_token["email"]
  end

  @spec name(id_token :: map) :: String.t()
  def name(id_token) do
    id_token["name"]
  end

  # Returns a link to the picture
  @spec picture(id_token :: map) :: String.t()
  def picture(id_token) do
    id_token["picture"]
  end
end
