defmodule Collaborlist.Invites.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:invite_code, :binary_id, autogenerate: true}

  schema "users" do
    belongs_to :list, Collaborlist.Catalog.List
    belongs_to :user, Collaborlist.Account.User

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:invite_code])
    |> validate_required([:invite_code])
  end
end
