defmodule SiresTaskApi.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def up do
    create table(:projects) do
      add :name, :string, null: false
      add :creator_id, references(:users, on_delete: :delete_all), null: false
      add :editor_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:projects, :name)
    create index(:projects, :creator_id)
    create index(:projects, :editor_id)
    create index(:projects, :updated_at)

    create table(:tags) do
      add :name, :string, null: false
      add :creator_id, references(:users, on_delete: :delete_all), null: false
      add :editor_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:tags, :name)
    create index(:tags, :creator_id)
    create index(:tags, :editor_id)

    create table(:project_members) do
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :role, :string, null: false, default: "regular"
      timestamps(updated_at: false)
    end

    create index(:project_members, :project_id)
    create index(:project_members, :user_id)
    create unique_index(:project_members, [:project_id, :user_id])

    create table(:tasks) do
      add :name, :string, null: false
      add :description, :text
      add :start_time, :timestamp
      add :finish_time, :timestamp
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :creator_id, references(:users, on_delete: :delete_all), null: false
      add :editor_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:tasks, :project_id)
    create index(:tasks, :start_time)
    create index(:tasks, :finish_time)

    create table(:task_members, primary_key: false) do
      add :task_id, references(:tasks, on_delete: :delete_all), null: false, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all), null: false, primary_key: true
      add :role, :string, null: false, default: "assignee"
      timestamps(updated_at: false)
    end

    create index(:task_members, :task_id)
    create index(:task_members, :user_id)
    create unique_index(:task_members, [:task_id, :user_id])

    create table(:task_references) do
      add :parent_task_id, references(:tasks, on_delete: :delete_all), null: false
      add :child_task_id, references(:tasks, on_delete: :delete_all), null: false
      add :reference_type, :string, null: false, default: "subtask"
      timestamps(updated_at: false)
    end

    create index(:task_references, :parent_task_id)
    create index(:task_references, :child_task_id)
    create unique_index(:task_references, [:parent_task_id, :child_task_id, :reference_type])

    create table(:task_comments) do
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
      add :author_id, references(:users, on_delete: :delete_all), null: false
      add :text, :text
      timestamps()
    end

    create index(:task_comments, :task_id)
    create index(:task_comments, :author_id)
    create index(:task_comments, :inserted_at)

    create table(:task_tags, primary_key: false) do
      add :task_id, references(:tasks, on_delete: :delete_all), null: false, primary_key: true
      add :tag_id, references(:tags, on_delete: :delete_all), null: false, primary_key: true
    end

    create index(:task_tags, :task_id)
    create index(:task_tags, :tag_id)

    create table(:attachments) do
      add :file, :text, null: false
      add :task_id, references(:tasks, on_delete: :delete_all)
      add :comment_id, references(:task_comments, on_delete: :delete_all)
      timestamps(updated_at: false)
    end

    create index(:attachments, :task_id)
    create index(:attachments, :comment_id)
    create index(:attachments, :inserted_at)
  end

  def down do
    drop table(:attachments)
    drop table(:task_tags)
    drop table(:task_comments)
    drop table(:task_references)
    drop table(:task_members)
    drop table(:tasks)
    drop table(:tags)
    drop table(:project_members)
    drop table(:projects)
  end
end
