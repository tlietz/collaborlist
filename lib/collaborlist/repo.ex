defmodule Collaborlist.Repo do
  use Ecto.Repo,
    otp_app: :collaborlist,
    adapter: Ecto.Adapters.Postgres
end
