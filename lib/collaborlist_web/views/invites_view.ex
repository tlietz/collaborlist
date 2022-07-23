defmodule CollaborlistWeb.InvitesView do
  use CollaborlistWeb, :view

  def invite_link(invite) do
    invite.invite_code
  end
end
