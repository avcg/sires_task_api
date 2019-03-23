defmodule SiresTaskApi.Repo.Migrations.AddDoneToTasks do
  use Ecto.Migration

  def up do
    alter table(:tasks) do
      add :done, :boolean, null: false, default: false
    end

    create index(:tasks, :done)
  end

  def down do
    alter table(:tasks) do
      remove :done
    end
  end
end
