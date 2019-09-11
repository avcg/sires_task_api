defmodule SiresTaskApi.Repo.Migrations.AddLocaleToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :locale, :string, null: false, default: "en"
    end
  end

  def down do
    alter table(:users) do
      remove :locale
    end
  end
end
