defmodule CollaborlistWeb.Router do
  use CollaborlistWeb, :router

  import CollaborlistWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CollaborlistWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  # Google sign in uses its own CSRF protection that conflicts with Phoneix's :protect_from_forgery plug
  pipeline :google_sign_in do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CollaborlistWeb.LayoutView, :root}
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  ## ListController routes
  scope "/", CollaborlistWeb do
    pipe_through :browser

    resources "/", ListController, only: [:index]
  end

  scope "/", CollaborlistWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/", ListController, only: [:create, :new]
  end

  scope "/", CollaborlistWeb do
    pipe_through [:browser, :require_authenticated_user, :require_user_list_collaborator]

    resources "/", ListController, except: [:index, :new, :create, :edit, :update, :delete, :show]
    get "/:list_id", ListController, :edit
    put "/:list_id", ListController, :update
    delete "/:list_id", ListController, :delete
  end

  ##################################################################

  scope "/collab", CollaborlistWeb do
    pipe_through [:browser, :require_authenticated_user, :require_user_list_collaborator]

    resources "/lists/:list_id", CollabController, except: [:show]
  end

  ## Authentication routes

  scope "/", CollaborlistWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/google/login", CollaborlistWeb do
    pipe_through :google_sign_in

    post "/", GoogleUserController, :create
  end

  scope "/", CollaborlistWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", CollaborlistWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
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
