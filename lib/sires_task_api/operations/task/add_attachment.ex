defmodule SiresTaskApi.Task.AddAttachment do
  use SiresTaskApi.Operation,
    params: %{
      task_id!: :integer,
      attachment!: %{file!: SiresTaskApi.Attachment}
    }

  alias SiresTaskApi.{Repo, Task, TaskPolicy}

  def build(op) do
    op
    |> find(:task, schema: Task, id_path: [:task_id], preloads: [:project])
    |> authorize(:task, policy: TaskPolicy, action: :update)
    |> step(:create_attachment, &create_attachment(&1.task))
    |> suboperation(
      Task.AddAttachmentVersion,
      &%{
        task_id: op.params.task_id,
        attachment_id: &1.create_attachment.id,
        version: op.params.attachment
      }
    )
    |> step(:attachment, &preload_attachment(&1.create_attachment))
  end

  defp create_attachment(%Task{id: task_id}) do
    %Task.Attachment{task_id: task_id} |> Repo.insert()
  end

  defp preload_attachment(attachment) do
    {:ok, attachment |> Repo.preload(versions: :attachment)}
  end
end
