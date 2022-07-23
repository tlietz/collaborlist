defmodule CollaborlistWeb.InvitesView do
  use CollaborlistWeb, :view

  @dev_link "http://localhost:4000/lists/"
  @prod_link "https://www.collaborlist.com/lists/"

  def invite_link(invite) do
    if Mix.env() == :prod do
      prod_link(invite)
    else
      dev_link(invite)
    end
  end

  defp dev_link(invite) do
    "#{@dev_link}#{invite.list_id}/invite/#{invite.invite_code}"
  end

  defp prod_link(invite) do
    "#{@prod_link}#{invite.list_id}/invite/#{invite.invite_code}"
  end
end
