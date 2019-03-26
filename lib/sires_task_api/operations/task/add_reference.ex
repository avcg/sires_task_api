defmodule SiresTaskApi.Task.AddReference do
  use SiresTaskApi.Operation,
    params: %{task_id!: :integer, reference!: %{task_id!: :integer, reference_type!: :string}}

  alias SiresTaskApi.{Repo, Task, TaskPolicy}

  def call(op) do
    op
    |> find(:parent_task, schema: Task, id_path: [:task_id], preloads: [:project])
    |> authorize(:parent_task, policy: TaskPolicy, action: :update)
    |> find(:child_task, schema: Task, id_path: [:reference, :task_id], preloads: [:project])
    |> step(:ensure_project, &ensure_project(&1.parent_task, &1.child_task))
    |> step(:add_reference, fn %{parent_task: parent_task, child_task: child_task} ->
      add_reference(parent_task, child_task, op.params.reference[:reference_type])
    end)
  end

  defp ensure_project(parent_task, child_task) do
    if parent_task.project_id == child_task.project_id do
      {:ok, true}
    else
      {:error, :cannot_reference_a_task_from_another_project}
    end
  end

  defp add_reference(parent_task, child_task, reference_type) do
    %Task.Reference{parent_task: parent_task, child_task: child_task}
    |> Ecto.Changeset.change(%{reference_type: reference_type})
    |> Ecto.Changeset.validate_inclusion(:reference_type, ~w(subtask blocker))
    |> Ecto.Changeset.unique_constraint(:reference_type, name: :task_references_pkey)
    |> Repo.insert()
  end
end
