defmodule SiresTaskApi.Task.Update do
  use SiresTaskApi.Operation,
    params: %{
      id!: :integer,
      task!: %{
        name: :string,
        description: :string,
        start_time: :utc_datetime,
        finish_time: :utc_datetime,
        tag_ids: {:array, :integer},
        attachments: [%{file: SiresTaskApi.Attachment}]
      }
    }

  alias SiresTaskApi.{Repo, Task, TaskPolicy}
  import Task.SharedHelpers

  def call(op) do
    op
    |> find(:task, schema: Task, preloads: [:project, :tags, attachments: :versions])
    |> authorize(:task, policy: TaskPolicy, action: :update)
    |> step(:tags, fn _ -> {:ok, find_tags(op.params.task[:tag_ids])} end)
    |> step(:update_task, &update_task(&1.task, op.params.task, &1.tags, op.context.user))
    |> step(:upload_files, &upload_attachments(&1.update_task, op.params.task[:attachments]))
  end

  def update_task(task, params, tags, editor) do
    task
    |> changeset(params, tags)
    |> Ecto.Changeset.put_change(:editor_id, editor.id)
    |> Repo.update()
  end
end
