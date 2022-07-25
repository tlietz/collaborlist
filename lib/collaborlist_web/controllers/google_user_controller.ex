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

        # TODO: If there is already an email associated with an account, but a Google sign-in was used, ask them if they want to merge the accounts.
        # TODO: Update a google account's email if it changes.
        # TODO: Add tests for new functionality

        google_user = id_token |> GoogleCerts.uid() |> Account.get_user_by_google_uid()

        if google_user do
          conn
          |> UserAuth.log_in_user(google_user)
          # this has the `external` tag because the `referer` from `get_req_header` returns a full URL.
          |> redirect(external: referer)
        else
          maybe_user = id_token |> GoogleCerts.email() |> Account.get_user_by_email()

          if maybe_user do
            # user is already registered with this email without a google account
            conn
            |> put_flash(:error, "Your email is already registered to an account")
            |> redirect(to: Routes.list_path(conn, :index))
          else
            current_user = conn.assigns[:current_user]

            {:ok, new_google_user} =
              if current_user && current_user.is_guest == true do
                Account.guest_no_more(current_user, %{
                  email: id_token |> GoogleCerts.email(),
                  google_uid: id_token |> GoogleCerts.uid()
                })
              else
                Account.register_user(%{
                  email: id_token |> GoogleCerts.email(),
                  google_uid: id_token |> GoogleCerts.uid()
                })
              end

            conn
            |> UserAuth.log_in_user(new_google_user)
            |> put_flash(
              :info,
              "Registered with new Google account"
            )
            |> redirect(external: referer)
          end
        end

      {:error, reason} ->
        conn
        |> put_flash(:error, "Sign in failed because #{reason}")
        |> redirect(to: Routes.list_path(conn, :index))
    end
  end
end
