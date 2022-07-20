defmodule Collaborlist.Catalog.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :title, :string

    has_many :list_items, Collaborlist.List.ListItem
    has_many :invites, Collaborlist.Invites.Invite

    many_to_many :users, Collaborlist.Account.User,
      on_delete: :delete_all,
      join_through: "users_lists",
      on_replace: :delete

    timestamps()
  end

  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title])
  end

  def changeset_update_collaborators(list, users) do
    list
    |> cast(%{}, [:title])
    |> put_assoc(:users, users)
  end
end
