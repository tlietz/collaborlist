defmodule Collaborlist.Helpers do
  @dev_link "http://localhost:4000"
  @prod_link "https://www.collaborlist.com"

  def root_url() do
    if Mix.env() == :prod do
      @prod_link
    else
      @dev_link
    end
  end
end