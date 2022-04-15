defmodule Collaborlist.Repo.Migrations.CreateListItems do
  use Ecto.Migration

  def change do
    create table(:list_items) do
      add :content, :string
      add :checked, :boolean, default: false, null: false
      add :striked, :boolean, default: false, null: false

      add :list_id, references(:lists, on_delete: :delete_all)

      timestamps()
    end

    create index(:list_items, [:list_id])
  end
end