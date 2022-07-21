defmodule CollaborlistWeb.InvitesController do
  use CollaborlistWeb, :controller

  def process_invite(conn, params) do
    params["invite_code"]
    |> IO.inspect(label: "params")
  end
end
