defmodule SiresTaskApi.Task.RemoveReference do
  use SiresTaskApi.Operation, params: %{task_id!: :integer, id!: :integer}
  alias SiresTaskApi.{Repo, Task, TaskPolicy}

  def call(op) do
    op
    |> find(:parent_task, schema: Task, id_path: [:task_id], preloads: [:project])
    |> authorize(:parent_task, policy: TaskPolicy, action: :update)
    |> step(:reference, &find_reference(&1.parent_task, op.params.id))
    |> step(:remove_reference, &Repo.delete(&1.reference))
  end

  defp find_reference(parent_task, child_task_id) do
    Task.Reference
    |> Repo.get_by(parent_task_id: parent_task.id, child_task_id: child_task_id)
    |> case do
      %Task.Reference{} = reference -> {:ok, reference}
      nil -> {:error, :not_found}
    end
  end
end
