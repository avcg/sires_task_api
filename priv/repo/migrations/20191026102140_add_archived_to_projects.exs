defmodule SiresTaskApi.Repo.Migrations.AddArchivedToProjects do
  use Ecto.Migration

  def up do
    alter table(:projects) do
      add :archived, :boolean, null: false, default: false
    end
  end

  def down do
    alter table(:projects) do
      remove :archived
    end
  end
end
