defmodule Collaborlist.Repo.Migrations.CreateUsersLists do
  use Ecto.Migration

  def change do
    create table(:users_lists, primary_key: false) do
      add(:user_id, references(:users), primary_key: true)
      add(:list_id, references(:lists), primary_key: true)

      timestamps()
    end

    create(index(:users_lists, [:user_id]))
    create(index(:users_lists, [:list_id]))
  end
end
