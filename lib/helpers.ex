defmodule Collaborlist.Helpers do
  @dev_link "http://localhost:4000"
  @prod_link "https://collaborlist.tlietz.com"

  def root_url() do
    if System.get_env("MIX_ENV") == "prod" do
      @prod_link
    else
      @dev_link
    end
  end

  def max_invites() do
    5
  end
end
