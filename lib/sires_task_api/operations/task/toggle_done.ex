defmodule SiresTaskApi.Task.ToggleDone do
  use SiresTaskApi.Operation, params: %{id!: :integer, done!: :boolean}
  alias SiresTaskApi.{Repo, Task, TaskPolicy}

  def call(op) do
    op
    |> find(:task, schema: Task, preloads: [:project])
    |> authorize(:task, policy: TaskPolicy, action: :toggle_done)
    |> step(:update_task, &toggle_done(&1.task, op.params.done))
  end

  defp toggle_done(task, done) do
    task |> Ecto.Changeset.change(%{done: done}) |> Repo.update()
  end
end
