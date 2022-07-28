defmodule CollaborlistWeb.InvitesController do
  use CollaborlistWeb, :controller

  alias Collaborlist.Invites
  alias Collaborlist.Catalog

  # TODO: Write tests for invite controller

  def index(conn, %{"list_id" => list_id}) do
    user = conn.assigns[:current_user]

    if user do
      invites = Invites.list_invites(user, list_id)
      render(conn, "index.html", invites: invites, list_id: list_id)
    else
      render(conn, "index.html", invite_links: [])
    end
  end

  def create(conn, %{"list_id" => list_id}) do
    user = conn.assigns[:current_user]
    list = Catalog.get_list!(list_id)

    case Invites.create_invite(user, list) do
      {:ok, _invite} ->
        conn
        |> redirect(to: Routes.invites_path(conn, :index, list_id))

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "error occured while trying to create invite link")
        |> redirect(to: Routes.invites_path(conn, :index, list_id))
    end
  end

  def delete(conn, %{"list_id" => list_id, "invite_code" => invite_code}) do
    invite = Invites.get_invite!(invite_code)
    {:ok, _invite} = Invites.delete_invite(invite)

    conn
    |> redirect(to: Routes.invites_path(conn, :index, list_id))
  end

  def process_invite(conn, %{"invite_code" => invite_code}) do
    invite = Invites.get_invite(invite_code)

    if invite do
      user = conn.assigns[:current_user]

      if user && user.is_guest == false do
        # Don't need to check if the list exists,
        # because anytime a list that an invite is deleted,
        # all invites to that list are also deleted.
        _ = Catalog.add_collaborator(invite, user)

        conn
        |> put_flash(:info, "Invite code successfull")
        |> redirect(to: Routes.collab_path(conn, :index, invite.list_id))
      else
      end
    else
      conn
      |> put_flash(:error, "Invite code invalid")
      |> redirect(to: Routes.list_path(conn, :index))
    end
  end
end
