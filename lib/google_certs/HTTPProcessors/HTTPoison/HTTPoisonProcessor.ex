defmodule GoogleCerts.HTTPProcessor.HTTPoisonProcessor do
  @behaviour GoogleCerts.HTTPProcessor

  @impl true
  @spec jwks(HTTPoison.Response.t()) :: %{required(String.t()) => map}
  def jwks(res = %HTTPoison.Response{}) do
    res |> extract_keys() |> to_jwk_map()
  end

  @impl true
  @spec seconds_to_expire(HTTPoison.Response.t()) :: integer()
  def seconds_to_expire(res = %HTTPoison.Response{}) do
    age = res |> age()
    max_age = res |> max_age()

    max_age - age
  end

  @impl true
  @spec get(String.t()) :: {:ok, response :: HTTPoison.Response.t()} | {:error, any}
  def get(url) do
    HTTPoison.get(url)
  end

  # Helper Functions

  @spec extract_keys(HTTPoison.Response.t()) :: %{}
  def extract_keys(res = %HTTPoison.Response{}) do
    res.body
    |> Jason.decode!()
  end

  def to_jwk_map(keys = %{}) do
    Enum.map(keys, fn {key_id, pem_key} -> {key_id, JOSE.JWK.from_pem(pem_key)} end)
    |> Map.new()
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
    raise GoogleCerts.InternalError, message: "Could not find max-age value"
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
    raise GoogleCerts.InternalError, message: "Could not find header '#{header}'"
  end
end
