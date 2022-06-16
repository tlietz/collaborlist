defmodule GoogleCerts.HTTPProcessor.Mock do
  @behaviour GoogleCerts.HTTPProcessor

  @impl true
  def jwks(example_jwks \\ %{}) do
    example_jwks
  end

  @impl true
  def seconds_to_expire(_res) do
    1000
  end

  @impl true
  def get(example_res \\ %{}) do
    {:ok, example_res}
  end
end
