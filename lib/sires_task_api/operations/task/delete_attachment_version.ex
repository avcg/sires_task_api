defmodule SiresTaskApi.Task.DeleteAttachmentVersion do
  use SiresTaskApi.Operation,
    params: %{
      task_id!: :integer,
      attachment_id!: :integer,
      id!: :integer
    }

  alias SiresTaskApi.{Repo, Task, TaskPolicy}
  import Task.SharedHelpers

  def build(op) do
    op
    |> find(:task, schema: Task, id_path: [:task_id], preloads: [:project])
    |> authorize(:task, policy: TaskPolicy, action: :update)
    |> find(:attachment, schema: Task.Attachment, id_path: [:attachment_id], preloads: [:versions])
    |> step(:ensure_task_id, &ensure_task_id(&1.attachment, op.params.task_id))
    |> find(:version, schema: Task.Attachment.Version)
    |> step(:ensure_attachment_id, &ensure_attachment_id(&1.version, op.params.attachment_id))
    |> step(:delete_version, &delete_version(&1.version))
    |> step(:delete_empty_attachment, &delete_empty_attachment(&1.attachment))
  end

  defp ensure_attachment_id(%{attachment_id: attachment_id}, attachment_id), do: {:ok, true}
  defp ensure_attachment_id(_, _), do: {:error, :not_found}

  defp delete_version(version) do
    version |> Repo.delete()
    {:ok, true}
  end

  defp delete_empty_attachment(attachment) do
    if length(attachment.versions) <= 1 do
      attachment |> Repo.delete()
      {:ok, true}
    else
      {:ok, false}
    end
  end
end
