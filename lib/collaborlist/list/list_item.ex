defmodule Collaborlist.List.ListItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "list_items" do
    field :content, :string
    field :status, Ecto.Enum, values: [:checked, :striked, :none]

    belongs_to :list, Collaborlist.Catalog.List

    timestamps()
  end

  def changeset(list_item, attrs) do
    list_item
    |> cast(attrs, [:content, :status])
    |> validate_required([:list_id])
  end
end
