defmodule GoogleCerts do
  @moduledoc """
  Has client functions to access Google auth public keys.
  Stores the keys and automatically renews them when they are close to becoming stale.
  """

  use GenServer

  # Client

  def start_link(default) when is_list(default) do
    # url for PEM encoded keys
    url = "https://www.googleapis.com/oauth2/v1/certs"

    res = HTTPoison.get!(url)

    GenServer.start_link(__MODULE__, extract_keys(res), name: __MODULE__)
  end

  def keys() do
    GenServer.call({:global, __MODULE__}, :keys)
  end

  # Server (callbacks)

  @impl true
  def init(keys) do
    {:ok, keys}
  end

  @impl true
  def handle_call(:keys, _from, keys) do
    {:reply, keys, keys}
  end

  # Helper Functions

  @spec extract_keys(HTTPoison.Response.t()) :: %{}
  def extract_keys(res = %HTTPoison.Response{}) do
    res.body
    |> Jason.decode!()
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
    {:error, "Could not find max-age value"}
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
    {:error, "could not find header '#{header}'"}
  end
end
