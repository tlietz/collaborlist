defmodule Collaborlist.Catalog.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
