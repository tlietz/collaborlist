defmodule CollaborlistWeb.InvitesController do
  use CollaborlistWeb, :controller

  alias Collaborlist.Invites
  alias Collaborlist.Invites.Invite

  alias Collaborlist.Catalog

  def index(conn, %{"list_id" => list_id}) do
    user = conn.assigns[:current_user]

    if user do
      invites = Invites.list_invites(user, list_id)
      render(conn, "index.html", invites: invites, list_id: list_id)
    else
      render(conn, "index.html", invites: [])
    end
  end

  def create(conn, %{"list_id" => list_id}) do
    user = conn.assigns[:current_user]
    list = Catalog.get_list!(list_id)

    case Invites.create_invite(user, list) do
      {:ok, invite} ->
        conn
        |> redirect(to: Routes.invites_path(conn, :index, list))

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "error occured while trying to create invite link")
        |> redirect(to: Routes.invites_path(conn, :index, list))
    end
  end

  def delete(conn, %{"list_id" => list_id, "invite_code" => invite_code}) do
    invite = Invites.get_invite!(invite_code)
    {:ok, _invite} = Invites.delete_invite(invite)

    conn
    |> redirect(to: Routes.invites_path(conn, :index, list_id))
  end

  defp invite_link(invite) do
    invite.invite_code
  end

  def process_invite(conn, params) do
    conn
    |> IO.inspect(label: "conn")

    params["invite_code"]
    |> IO.inspect(label: "params")
  end
end
