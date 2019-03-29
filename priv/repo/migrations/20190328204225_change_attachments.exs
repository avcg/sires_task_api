defmodule SiresTaskApi.Repo.Migrations.ChangeAttachments do
  use Ecto.Migration

  def change do
    drop table(:attachments)

    create table(:task_attachments) do
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
    end

    create index(:task_attachments, :task_id)

    create table(:task_attachment_versions) do
      add :attachment_id, references(:task_attachments, on_delete: :delete_all), null: false
      add :file, :text
      timestamps(updated_at: false)
    end

    create index(:task_attachment_versions, :attachment_id)
    create index(:task_attachment_versions, :inserted_at)

    create table(:task_comment_attachments) do
      add :comment_id, references(:task_comments, on_delete: :delete_all), null: false
      add :file, :text
    end

    create index(:task_comment_attachments, :comment_id)
  end
end
