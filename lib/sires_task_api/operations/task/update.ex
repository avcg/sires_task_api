defmodule SiresTaskApi.Task.Update do
  use SiresTaskApi.Operation,
    params: %{
      id!: :integer,
      task!: %{
        name: :string,
        description: :string,
        start_time: :utc_datetime,
        finish_time: :utc_datetime
      }
    }

  alias SiresTaskApi.{Repo, Task, TaskPolicy}

  def call(op) do
    op
    |> find(:task, schema: Task, preloads: [:project])
    |> authorize(:task, policy: TaskPolicy, action: :update)
    |> step(:update_task, &update_task(&1.task, op.params.task, op.context.user))
  end

  def update_task(task, params, editor) do
    task
    |> Task.SharedHelpers.changeset(params)
    |> Ecto.Changeset.put_change(:editor_id, editor.id)
    |> Repo.update()
  end
end
