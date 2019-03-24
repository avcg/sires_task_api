defmodule SiresTaskApi.Repo.Migrations.ChangeUsersEmailIndex do
  use Ecto.Migration

  def up do
    drop unique_index(:users, [:email])
    create unique_index(:users, ["lower(email)"])
  end

  def down do
    drop unique_index(:users, ["lower(email)"])
    create unique_index(:users, [:email])
  end
end
