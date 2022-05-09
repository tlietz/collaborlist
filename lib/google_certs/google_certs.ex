defmodule GoogleCerts do
  # TODO: One hour before the keys go stale, grab the next keys from url and retry until successfull. Then, add the new keys to the cache, keeping track of which key_id are new or updated. Once the old keys go stale, remove them from the cache. Some of this info should be stored in the state of the genserver
  @moduledoc """
  Stores the public Google cert keys in ETS and automatically renews them when they are close to becoming stale.

  The client jwk/1 function returns a JOSE jwk that is ready to be verified with JOSE.JWT.verify_strict/3

  There are no server calls implemented other than init/1, because otherwise the genserver would become a bottleneck
  for reading keys. The client keys/0 function reads the keys from ETS, which is used for its built in concurrency.
  """

  use GenServer

  @table :google_key_cache

  # Client

  def start_link(default) when is_list(default) do
    create_key_cache()

    populate_key_cache(HTTPoison.get!("https://www.googleapis.com/oauth2/v1/certs"))

    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def jwk(key_id) do
    :ets.lookup(@table, "jwks") |> jwk_from_ets(key_id)
  end

  def jwk_from_ets(table, key_id) do
    [{_, jwks}] = table
    jwks[key_id]
  end

  def create_key_cache() do
    :ets.new(@table, [:named_table])
  end

  def populate_key_cache(res = %HTTPoison.Response{}) do
    :ets.insert(@table, {"jwks", jwks(res)})
  end

  # Server (callbacks)

  @impl true
  def init(keys) do
    {:ok, keys}
  end

  # Helper Functions

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
