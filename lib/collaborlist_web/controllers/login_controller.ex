defmodule CollaborlistWeb.LoginController do
  use CollaborlistWeb, :controller

  def login(conn, params) do
    params |> IO.inspect(label: "LOGIN-PARAMS")
    conn
  end
end
