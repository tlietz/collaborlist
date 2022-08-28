defmodule CollaborlistWeb.Live.InviteModal do
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="<%= @id %>">
      <%= render_slot(@inner_block, []) %>
    </div>
    """
  end
end
