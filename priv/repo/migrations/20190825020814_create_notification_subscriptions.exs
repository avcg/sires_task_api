defmodule SiresTaskApi.Repo.Migrations.CreateNotificationSubscriptions do
  use Ecto.Migration

  def up do
    create table(:notification_subscriptions, primary_key: false) do
      add :media, :string, null: false, primary_key: true
      add :operation, :string, null: false, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all), null: false, primary_key: true
    end

    create index(:notification_subscriptions, :user_id)
  end

  def down do
    drop table(:notification_subscriptions)
  end
end
