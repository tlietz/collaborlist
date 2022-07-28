defmodule Collaborlist.Invites.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:invite_code, :string, autogenerate: false}

  schema "invites" do
    belongs_to :list, Collaborlist.Catalog.List
    belongs_to :user, Collaborlist.Account.User

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [])
    |> gen_invite_code()
    |> validate_required([:invite_code, :user_id, :list_id])
  end

  defp gen_invite_code(changeset) do
    changeset
    |> Map.put(
      :changes,
      changeset.changes
      |> Map.put(
        :invite_code,
        Ecto.UUID.generate()
      )
    )
  end
end
