defmodule Collaborlist.Catalog.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :title, :string

    has_many :list_items, Collaborlist.List.ListItem
    many_to_many :lists, Collaborlist.Account.User, join_through: "users_lists"

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title])
  end
end
