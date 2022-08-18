defmodule Collaborlist.List.ListItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "list_items" do
    field :content, :string
    field :checked, :boolean, default: false
    field :striked, :boolean, default: false

    belongs_to :list, Collaborlist.Catalog.List

    timestamps()
  end

  def changeset(list_item, attrs) do
    list_item
    |> cast(attrs, [:content, :checked, :striked])
    |> validate_required([:content, :list_id])
  end
end
