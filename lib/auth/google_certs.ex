defmodule GoogleCerts do
  @moduledoc """
  Has client functions to access Google auth public keys.
  Stores the keys and automatically renews them when they are close to becoming stale.
  """

  use GenServer
end
