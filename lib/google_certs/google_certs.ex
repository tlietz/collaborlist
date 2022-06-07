defmodule GoogleCerts do
  @moduledoc """
  Stores the public Google cert keys in ETS and automatically renews them when they are close to becoming stale.

  The client jwk/1 function returns a JOSE jwk that is ready to be verified with JOSE.JWT.verify_strict/3

  There are no server calls implemented for reading keys, because otherwise the genserver process would become a bottleneck.
  """

  @table :google_key_cache

  # User-facing client
  # This does not make a call to the Genserver process.

  def jwk(key_id) do
    :ets.lookup(@table, "jwks") |> jwk_from_ets(key_id)
  end

  def jwk_from_ets(table, key_id) do
    [{_, jwks}] = table
    jwks[key_id]
  end
end
