defmodule CollaborlistWeb.InviteController do
  use CollaborlistWeb, :controller

  def process_invite(conn, params) do
    params
    |> IO.inspect(label: "params")
  end
end
