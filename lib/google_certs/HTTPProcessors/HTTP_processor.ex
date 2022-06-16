defmodule GoogleCerts.HTTPProcessor do
  @moduledoc """
  Defines a behavior for the primary GoogleCerts module to call so that the
  HTTP Client used to get the JWKs is decoupled from the genserver implementation.
  """

  @type jwk_map :: %{required(String.t()) => map}

  @doc "Returns a map of JWKs that will be inserted into the ETS key cache"
  @callback jwks(response :: map) :: jwk_map

  @doc "Returns the seconds until the HTTP/S response expires"
  @callback seconds_to_expire(response :: map) :: integer()

  @doc "Executes a GET request to the specified URL"
  @callback get(url :: String.t()) :: {:ok, response :: map} | {:error, any}
end
