defmodule SiresTaskApi.Task.Delete do
  use SiresTaskApi.Operation, params: %{id!: :integer}
  alias SiresTaskApi.{Repo, Task, TaskPolicy}

  def call(op) do
    op
    |> find(:task, schema: Task, preloads: [:project])
    |> authorize(:task, policy: TaskPolicy, action: :delete)
    |> step(:delete_task, &Repo.delete(&1.task))
  end
end
