defmodule CollaborlistWeb.Router do
  use CollaborlistWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CollaborlistWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :catalog do
    plug :fetch_lists
  end

  defp fetch_current_user(conn, _) do
    conn
  end

  defp fetch_lists(conn, _) do
    conn
  end

  pipeline :collab do
    plug :fetch_current_list
    plug :fetch_list_items
  end

  defp fetch_current_list(conn, _) do
    conn
  end

  defp fetch_list_items(conn, _) do
    conn
  end

  scope "/", CollaborlistWeb do
    pipe_through :browser
    pipe_through :catalog

    resources "/lists", ListController, except: [:show]

    post "/login", SessionController, :login
  end

  scope "/collab", CollaborlistWeb do
    pipe_through :browser
    pipe_through :collab

    resources "/lists/:list_id", CollabController, except: [:show]
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CollaborlistWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
