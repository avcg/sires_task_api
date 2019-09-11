defmodule SiresTaskApi.Task.AddAttachmentVersion do
  use SiresTaskApi.Operation,
    params: %{
      task_id!: :integer,
      attachment_id!: :integer,
      version!: %{file!: SiresTaskApi.Attachment}
    }

  alias SiresTaskApi.{Repo, Task, TaskPolicy}
  import Task.SharedHelpers

  def build(op) do
    op
    |> find(:task, schema: Task, id_path: [:task_id], preloads: [:project])
    |> authorize(:task, policy: TaskPolicy, action: :update)
    |> find(:attachment, schema: Task.Attachment, id_path: [:attachment_id])
    |> step(:ensure_task_id, &ensure_task_id(&1.attachment, op.params.task_id))
    |> step(:add_version, &Repo.insert(%Task.Attachment.Version{attachment: &1.attachment}))
    |> step(:upload_file, &upload_file(&1.add_version, op.params.version))
  end

  defp upload_file(attachment, params) do
    attachment
    |> attachment_changeset(params)
    |> Repo.update()
  end
end
