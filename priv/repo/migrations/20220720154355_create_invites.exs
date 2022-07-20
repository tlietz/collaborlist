defmodule Collaborlist.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :uuid, :uuid, primary_key: true

      add :list_id, references(:lists, on_delete: :delete_all)

      timestamps()
    end

    create index(:users, [:list_id])
  end
end
