defmodule CollaborlistWeb.InvitesController do
  use CollaborlistWeb, :controller

  alias Collaborlist.Invites
  alias Collaborlist.Invites.Invite

  alias Collaborlist.Catalog

  def index(conn, %{"list_id" => list_id}) do
    user = conn.assigns[:current_user]

    if user do
      lists = Catalog.list_lists(user)
      render(conn, "index.html", lists: lists)
    else
      render(conn, "index.html", lists: [])
    end
  end

  def create(conn, %{"list_id" => list_id}) do
    user = conn.assigns[:current_user]
    list = Catalog.get_list!(list_id)

    case Invites.create_invite(list, user) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Invite link: #{invite_link(invite)}")
        |> redirect(to: Routes.invites_path(conn, :index, list))

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "error occured while trying to create invite link")
        |> redirect(to: Routes.invites_path(conn, :index, list))
    end
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
