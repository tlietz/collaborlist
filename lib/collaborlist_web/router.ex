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
    plug :maybe_guest_flash
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

  # TODO: Purge guests after the max forget me time is reached

  ## ListController routes

  scope "/", CollaborlistWeb do
    pipe_through [:browser, :maybe_assign_guest_user]

    live "/", ListLive, :index
  end

  scope "/lists", CollaborlistWeb do
    pipe_through [:browser, :maybe_assign_guest_user, :require_authenticated_user]

    get "/new", ListController, :new
    post "/", ListController, :create
  end

  scope "/lists", CollaborlistWeb do
    pipe_through [
      :browser,
      :maybe_assign_guest_user,
      :require_authenticated_user,
      :require_user_list_collaborator
    ]

    get "/:list_id", ListController, :edit
    put "/:list_id", ListController, :update
    delete "/:list_id", ListController, :delete
  end

  ## Collab routes

  scope "/lists/:list_id/collab", CollaborlistWeb do
    pipe_through [
      :browser,
      :maybe_assign_guest_user,
      :require_authenticated_user,
      :require_user_list_collaborator
    ]

    live "/list_items/", CollabLive, :index
    resources "/list_items/", CollabController, except: [:show, :index]
  end

  ## Invite routes

  scope "/", CollaborlistWeb do
    # TODO display a selection screen if a user is not logged in asking if they want to continue as guest, register, or login
    pipe_through [:browser, :maybe_assign_guest_user]

    get "/invites/:invite_code", InvitesController, :process_invite
  end

  scope "/lists/:list_id/collab/invites", CollaborlistWeb do
    pipe_through [
      :browser,
      :maybe_assign_guest_user,
      :require_authenticated_user,
      :require_user_list_collaborator
    ]

    live "/", CollabLive, :invite_modal
    post "/", InvitesController, :create
  end

  scope "/lists/:list_id/collab/invites", CollaborlistWeb do
    pipe_through [
      :browser,
      :require_authenticated_user,
      :require_user_list_collaborator,
      :require_user_invite_creator
    ]

    delete "/:invite_code", InvitesController, :delete
  end

  ## Authentication routes

  scope "/", CollaborlistWeb do
    pipe_through [:browser, :redirect_if_user_is_logged_in]

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
    delete "/users/settings/", UserSettingsController, :delete
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
