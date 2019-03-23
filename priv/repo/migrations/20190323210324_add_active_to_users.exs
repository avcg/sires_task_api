defmodule SiresTaskApi.Repo.Migrations.AddActiveToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :active, :boolean, null: false, default: true
    end
  end

  def down do
    alter table(:users) do
      remove :active
    end
  end
end
