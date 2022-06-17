defmodule GoogleCerts do
  @moduledoc """
  TODO: documentation
  """

  @type milliseconds :: Integer.t()
  @type seconds :: Integer.t()

  # Client facing functions
  @spec user_jwt(conn :: any, params :: any) ::
          {:error, any} | {:ok, jwt :: map}
  def user_jwt(conn, params) do
    with {:ok, _token} <- verify_csrf_token(conn, params),
         {:ok, jwt} <- verify_id_token(conn, params) do
      {:ok, jwt.fields}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec verify_id_token(any, nil | maybe_improper_list | map) ::
          {:error, any} | {:ok, JOSE.JWT.t()}
  defdelegate verify_id_token(conn, params), to: GoogleCerts.Authentication

  @spec verify_csrf_token(any, nil | maybe_improper_list | map) ::
          {:error, any} | {:ok, any}
  defdelegate verify_csrf_token(conn, params), to: GoogleCerts.CSRF

  # Helper
end
