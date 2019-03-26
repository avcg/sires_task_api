defmodule SiresTaskApi.Task.Update do
  use SiresTaskApi.Operation,
    params: %{
      id!: :integer,
      task!: %{
        name: :string,
        description: :string,
        start_time: :utc_datetime,
        finish_time: :utc_datetime,
        tag_ids: {:array, :integer}
      }
    }

  alias SiresTaskApi.{Repo, Task, TaskPolicy}

  def call(op) do
    op
    |> find(:task, schema: Task, preloads: [:project, :tags])
    |> authorize(:task, policy: TaskPolicy, action: :update)
    |> step(:tags, fn _ -> {:ok, Task.SharedHelpers.find_tags(op.params.task[:tag_ids])} end)
    |> step(:update_task, &update_task(&1.task, op.params.task, &1.tags, op.context.user))
  end

  def update_task(task, params, tags, editor) do
    task
    |> Task.SharedHelpers.changeset(params, tags)
    |> Ecto.Changeset.put_change(:editor_id, editor.id)
    |> Repo.update()
  end
end
