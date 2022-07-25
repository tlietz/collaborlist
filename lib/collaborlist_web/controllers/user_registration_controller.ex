defmodule CollaborlistWeb.UserRegistrationController do
  use CollaborlistWeb, :controller

  alias Collaborlist.Account
  alias Collaborlist.Account.User
  alias CollaborlistWeb.UserAuth

  # TODO: if user is a guest, register them by changing their user status guest and filling in the new username and password

  def new(conn, _params) do
    changeset = Account.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user = conn.assigns[:current_user]

    if user && user.is_guest == true do
      conn |> process_registration(Account.guest_no_more(user, user_params))
    else
      conn |> process_registration(Account.register_user(user_params))
    end
  end

  defp process_registration(conn, register_info) do
    case register_info do
      {:ok, user} ->
        {:ok, _} =
          Account.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
