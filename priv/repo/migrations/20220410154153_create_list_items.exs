defmodule Collaborlist.Repo.Migrations.CreateListItems do
  use Ecto.Migration

  def change do
    create table(:list_items) do
      add :content, :string
      add :status, :string, default: "none"

      add :list_id, references(:lists, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:list_items, [:list_id])
  end
end
