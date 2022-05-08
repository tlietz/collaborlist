defmodule Collaborlist.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Collaborlist.Repo,
      # Start the Telemetry supervisor
      CollaborlistWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Collaborlist.PubSub},
      # Start the Endpoint (http/https)
      CollaborlistWeb.Endpoint,
      # Start the Google Certs genserver
      GoogleCerts
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Collaborlist.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CollaborlistWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
