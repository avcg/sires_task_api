defmodule SiresTaskApi.Repo.Migrations.AddInboxProjectIdToUsers do
  use Ecto.Migration

  @inbox_project_name "Входящие"

  def up do
    drop unique_index(:projects, :name)

    alter table(:users) do
      add :inbox_project_id, :integer
    end

    execute "ALTER TABLE projects DROP CONSTRAINT projects_creator_id_fkey"
    execute "ALTER TABLE projects DROP CONSTRAINT projects_editor_id_fkey"

    alter table(:projects) do
      modify :creator_id, references(:users, on_delete: :nilify_all), null: true
      modify :editor_id, references(:users, on_delete: :nilify_all), null: true

      # temporary field
      add :inbox_user_id, :integer, null: false
    end

    execute """
    INSERT INTO projects (name, inserted_at, updated_at, inbox_user_id)
    SELECT '#{@inbox_project_name}', NOW(), NOW(), id
    FROM users
    """

    execute """
    UPDATE users AS u
    SET inbox_project_id = p.id
    FROM projects AS p
    WHERE p.inbox_user_id = u.id
    """

    alter table(:projects) do
      remove :inbox_user_id
    end

    alter table(:users) do
      modify :inbox_project_id, references(:projects, on_delete: :restrict), null: false
    end

    create unique_index(:users, :inbox_project_id)
  end

  def down do
    execute """
    UPDATE projects AS p
    SET creator_id = u.id,
        editor_id = u.id
    FROM users AS u
    WHERE u.inbox_project_id = p.id
    """

    execute "ALTER TABLE projects DROP CONSTRAINT projects_creator_id_fkey"
    execute "ALTER TABLE projects DROP CONSTRAINT projects_editor_id_fkey"

    alter table(:projects) do
      modify :creator_id, references(:users, on_delete: :delete_all), null: false
      modify :editor_id, references(:users, on_delete: :delete_all), null: false

      # tempoprary field
      add :inbox, :boolean, null: false, default: false
    end

    execute """
    UPDATE projects AS p
    SET inbox = TRUE
    FROM users AS u
    WHERE u.inbox_project_id = p.id
    """

    alter table(:users) do
      remove :inbox_project_id
    end

    execute "DELETE FROM projects WHERE inbox = TRUE"

    alter table(:projects) do
      remove :inbox
    end

    create unique_index(:projects, :name)
  end
end
