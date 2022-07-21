defmodule Collaborlist.Invites.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:invite_code, :binary_id, autogenerate: true}

  schema "invites" do
    belongs_to :list, Collaborlist.Catalog.List
    belongs_to :user, Collaborlist.Account.User

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [])
    |> validate_required([:user_id, :list_id])
  end
end
