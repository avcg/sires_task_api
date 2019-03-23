defmodule SiresTaskApi.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :role, :string, null: false, default: "regular"
    end
  end

  def down do
    alter table(:users) do
      remove :role
    end
  end
end
