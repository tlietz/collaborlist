defmodule GoogleCerts do
  @moduledoc """
  Stores the public Google cert keys in ETS and automatically renews them when they are close to becoming stale.

  The ETS key cache is setup such that reads can happen concurrently from any process,
  while writes are still serialized through only the GoogleCerts process.
  This prevents user sign-ins failing during the (really small) time intervals when the key cache is being written to.

  The client jwk/1 function returns a JOSE jwk that is ready to be verified with JOSE.JWT.verify_strict/3

  There are no server calls implemented for reading keys, because otherwise the genserver process would become a bottleneck.
  """

  use GenServer
  use Retry
  import GoogleCerts.HTTPProcessor.HTTPoisonProcessor

  alias GoogleCerts.Constants

  # ETS Key Cache client functions

  @spec jwk(String.t()) :: String.t()
  def jwk(key_id) do
    :ets.lookup(Constants.key_cache(), "jwks") |> jwk_from_ets(key_id)
  end

  def jwk_from_ets(table, key_id) do
    [{_, jwks}] = table
    jwks[key_id]
  end

  # Genserver client functions

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def maybe_create_key_cache(cache_name) do
    try do
      create_key_cache(cache_name)
    rescue
      # If an ETS cache already exists, do nothing and return a [] to satisfy the Elixir requirement that functions must return something.
      ArgumentError -> []
    end
  end

  defp create_key_cache(cache_name) do
    :ets.new(cache_name, [:protected, :named_table, read_concurrency: true])
  end

  @spec populate_key_cache(HTTPoison.Response.t()) :: HTTPoison.Response.t()
  def populate_key_cache(res = %HTTPoison.Response{}) do
    # Insert the new keys into the ETS key cache, replacing the old ones if there are any.
    :ets.insert(Constants.key_cache(), {"jwks", jwks(res)})
    res
  end

  # Server (callbacks)

  @impl true
  def init(_state) do
    _ = maybe_create_key_cache(Constants.key_cache())
    # initialize the cache and schedule the next time to refresh the keys
    {:ok, %{}, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, state) do
    _ = refresh_and_schedule_key_cache()
    {:noreply, state}
  end

  @impl true
  def handle_info(:refresh, state) do
    _ = refresh_and_schedule_key_cache()
    {:noreply, state}
  end

  defp schedule_key_cache_refresh(res) do
    # Refresh the keys in the ETS key cache 5 minutes before they expire
    Process.send_after(self(), :refresh, 1000 * ((res |> seconds_to_expire()) - 300))
    res
  end

  defp refresh_and_schedule_key_cache() do
    get_pem_keys(Constants.url(), 10_000) |> populate_key_cache() |> schedule_key_cache_refresh()
  end

  # Helper Functions

  @type milliseconds :: Integer.t()

  @spec get_pem_keys(url :: String.t(), expiry_time :: milliseconds) ::
          HTTPoison.Response.t() | GoogleCerts.InternalError
  def get_pem_keys(url, time) do
    # Retries the request for the specified time, then raises an internal error
    retry with: exponential_backoff() |> expiry(time) do
      get(url)
    after
      {:ok, res} -> res
    else
      _error ->
        raise GoogleCerts.InternalError,
          message: "Failed to retrieve PEM keys from Google certs endpoint"
    end
  end
end
