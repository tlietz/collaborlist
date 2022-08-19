defmodule CollaborlistWeb.InvitesView do
  use CollaborlistWeb, :view
  import Collaborlist.Helpers

  def invite_link(invite) do
    "#{root_url()}/invites/#{invite.invite_code}"
  end
end
