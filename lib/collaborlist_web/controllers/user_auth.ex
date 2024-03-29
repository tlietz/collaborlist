defmodule CollaborlistWeb.UserAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias Phoenix.LiveView
  alias Collaborlist.Account
  alias Collaborlist.Catalog
  alias Collaborlist.Invites
  alias CollaborlistWeb.Router.Helpers, as: Routes

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_collaborlist_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  def on_mount(:current_user, _params, session, socket) do
    case session do
      %{"user_token" => user_token} ->
        {:cont,
         LiveView.assign_new(socket, :current_user, fn ->
           Account.get_user_by_session_token(user_token)
         end)}

      %{} ->
        {:cont, LiveView.assign(socket, :current_user, nil)}
    end
  end

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_user(conn, user, params \\ %{}) do
    token = Account.generate_user_session_token(user)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Account.delete_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      CollaborlistWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: "/")
  end

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """
  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user = user_token && Account.get_user_by_session_token(user_token)
    assign(conn, :current_user, user)
  end

  defp ensure_user_token(conn) do
    if user_token = get_session(conn, :user_token) do
      {user_token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if user_token = conn.cookies[@remember_me_cookie] do
        {user_token, put_session(conn, :user_token, user_token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Creates, logs in, and fetches a guest user if no current user is logged in.
  This plug must be run after `fetch_current_user`
  because it relies on determining whether a user is fetched or not.
  """
  def maybe_assign_guest_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      {:ok, guest_user} = Account.register_guest_user()

      conn
      |> log_in_user(guest_user, %{"remember_me" => "true"})
      |> assign(:current_user, guest_user)
    end
  end

  @doc """
  Puts a flash if the user currently logge din is a guest.
  """
  def maybe_guest_flash(conn, _opts) do
    user = conn.assigns[:current_user]

    if user && user.is_guest do
      conn
      |> put_flash_if_currently_empty(
        :info,
        "Logged in as guest. If you want to access your lists from multiple devices, log in to an account."
      )
    else
      conn
    end
  end

  defp put_flash_if_currently_empty(conn, key, message) do
    flash = conn.private[:phoenix_flash]

    if(flash && Map.has_key?(flash, Atom.to_string(key))) do
      conn
    else
      conn
      |> put_flash(
        key,
        message
      )
    end
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_logged_in(conn, _opts) do
    user = conn.assigns[:current_user]

    if user && user.is_guest == false do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: Routes.list_path(conn, :index))
      |> halt()
    end
  end

  @doc """
  Used for routes that require the user to be a collaborator on a list.
  """
  def require_user_list_collaborator(conn, _opts) do
    if Catalog.list_collaborator?(
         conn.assigns[:current_user],
         maybe_to_integer(conn.params["list_id"])
       ) do
      conn
    else
      conn
      |> put_flash(:error, "You must be a collaborator on the list to do this action.")
      |> maybe_store_return_to()
      |> redirect(to: Routes.list_path(conn, :index))
      |> halt()
    end
  end

  defp maybe_to_integer(string?) when is_binary(string?) do
    String.to_integer(string?)
  end

  defp maybe_to_integer(string?) do
    string?
  end

  @doc """
  Used for routes that require the user to be the creator of an invite
  """
  def require_user_invite_creator(conn, _opts) do
    if Invites.invite_creator?(
         conn.assigns[:current_user],
         conn.params[
           "invite_code"
         ]
       ) do
      conn
    else
      conn
      |> put_flash(:error, "You must be the invite creator to do this action.")
      |> maybe_store_return_to()
      |> redirect(to: Routes.list_path(conn, :index))
      |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: "/"
end
