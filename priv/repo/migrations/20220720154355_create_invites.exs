defmodule Collaborlist.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :invite_code, :uuid, primary_key: true

      add :list_id, references(:lists, on_delete: :delete_all)

      timestamps()
    end

    create index(:invites, [:list_id])
  end
end
