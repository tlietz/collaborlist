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

    # a map with kid => key
    keys =
      res.body
      |> Jason.decode!()

    GenServer.start_link(__MODULE__, keys, name: __MODULE__)
  end

  def keys() do
    GenServer.call(__MODULE__, :keys)
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
end
