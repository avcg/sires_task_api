defmodule SiresTaskApi.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :position, :string
      add :avatar, :text
    end
  end

  def down do
    alter table(:users) do
      remove :first_name
      remove :middle_name
      remove :last_name
      remove :position
      remove :avatar
    end
  end
end
