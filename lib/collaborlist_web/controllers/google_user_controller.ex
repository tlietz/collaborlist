defmodule CollaborlistWeb.GoogleUserController do
  use CollaborlistWeb, :controller

  alias Collaborlist.Account
  alias CollaborlistWeb.UserAuth

  @spec create(Plug.Conn.t(), nil | maybe_improper_list | map) :: Plug.Conn.t()
  def create(conn, params) do
    case GoogleCerts.user_id_token(conn, params) do
      {:ok, id_token} ->
        [referer] =
          conn
          |> get_req_header("referer")

        # TODO: If there is already an email associated with an account, but a Google sign-in was used, popup and ask if user wants to use Google as default, or use both.
        # TODO: Auto logout feature for google account in settings

        google_user = id_token |> GoogleCerts.uid() |> Account.get_user_by_google_uid()

        if google_user do
          conn
          |> UserAuth.log_in_user(google_user)
          # this has the `external` tag because the `referer` from `get_req_header` returns a full URL.
          |> redirect(external: referer)
        else
          {:ok, new_google_user} =
            Account.register_user(%{
              email: id_token |> GoogleCerts.email(),
              google_uid: id_token |> GoogleCerts.uid()
            })

          conn
          |> UserAuth.log_in_user(new_google_user)
          |> put_flash(
            :info,
            "Registered with new Google account"
          )
          |> redirect(external: referer)
        end

      {:error, reason} ->
        conn
        |> put_flash(:error, "Sign in failed because #{reason}")
        |> redirect(to: Routes.list_path(conn, :index))
    end
  end
end
