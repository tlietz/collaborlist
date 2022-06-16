defmodule GoogleCerts.Constants do
  @moduledoc """
  Constants used by GoogleCerts.
  """

  @key_cache :google_key_cache
  @url "https://www.googleapis.com/oauth2/v1/certs"

  def url() do
    @url
  end

  def key_cache() do
    @key_cache
  end
end
