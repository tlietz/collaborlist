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

  @key_cache :google_key_cache
  @url "https://www.googleapis.com/oauth2/v1/certs"

  # ETS Key Cache client functions

  def jwk(key_id) do
    :ets.lookup(@key_cache, "jwks") |> jwk_from_ets(key_id)
  end

  def jwk_from_ets(table, key_id) do
    [{_, jwks}] = table
    jwks[key_id]
  end

  # Genserver client functions

  def start_link(default) when is_list(default) do
    _ = maybe_create_key_cache(@key_cache)

    # TODO: move this into its own function where the work of the genserver is defined.
    # TODO: This will be outside of start_link
    _ = populate_key_cache()

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
    :ets.new(cache_name, [:named_table, read_concurrency: true])
  end

  def populate_key_cache() do
    res = get_pem_keys(@url)
    :ets.insert(@key_cache, {"jwks", jwks(res)})
  end

  # Server (callbacks)

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  # Helper Functions

  @spec get_pem_keys(String.t()) :: HTTPoison.Response.t() | GoogleCerts.Error
  def get_pem_keys(url) do
    # Retries the request for a minute, then raises an error
    retry with: exponential_backoff() |> randomize |> expiry(10_000) do
      HTTPoison.get(url)
    after
      {:ok, res} -> res
    else
      _error ->
        raise GoogleCerts.InternalError,
          message: "Failed to retrieve PEM keys from Google certs endpoint"
    end
  end

  def jwks(res) do
    res |> extract_keys() |> to_jwk_map()
  end

  @spec extract_keys(HTTPoison.Response.t()) :: %{}
  def extract_keys(res = %HTTPoison.Response{}) do
    res.body
    |> Jason.decode!()
  end

  def to_jwk_map(keys = %{}) do
    Enum.map(keys, fn {key_id, pem_key} -> {key_id, JOSE.JWK.from_pem(pem_key)} end)
    |> Map.new()
  end

  @spec seconds_to_expire(HTTPoison.Response.t()) :: Integer.t()
  def seconds_to_expire(res = %HTTPoison.Response{}) do
    age = res |> age()
    max_age = res |> max_age()

    max_age - age
  end

  def age(res = %HTTPoison.Response{}) do
    {age, _} = res |> get_header("Age") |> Integer.parse()
    age
  end

  def max_age(res = %HTTPoison.Response{}) do
    res
    |> get_header("Cache-Control")
    |> String.split([",", "="])
    |> extract_max_age()
  end

  def extract_max_age([head | tail]) do
    if head |> String.trim_leading() |> String.starts_with?("max-age") do
      [max_age_string | _] = tail

      {max_age, _} =
        max_age_string
        |> Integer.parse()

      max_age
    else
      extract_max_age(tail)
    end
  end

  def extract_max_age([]) do
    raise GoogleCerts.Error, message: "Could not find max-age value"
  end

  @spec get_header(HTTPoison.Response.t(), any) :: String.t() | {:error, any}
  def get_header(res = %HTTPoison.Response{}, header) do
    res.headers |> get_header(header)
  end

  def get_header([head | tail], header) do
    {res_header, value} = head

    if res_header == header do
      value
    else
      get_header(tail, header)
    end
  end

  def get_header([], header) do
    raise GoogleCerts.Error, message: "Could not find header '#{header}'"
  end
end
