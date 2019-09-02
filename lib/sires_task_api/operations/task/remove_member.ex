defmodule SiresTaskApi.Task.RemoveMember do
  use SiresTaskApi.Operation, params: %{task_id!: :integer, id!: :integer, role!: :string}
  alias SiresTaskApi.{Repo, Task, TaskPolicy}

  def build(op) do
    op
    |> find(:task, schema: Task, id_path: [:task_id], preloads: [:project])
    |> authorize(:task, policy: TaskPolicy, action: :update)
    |> step(:member, &find_member(&1.task, op.params.id, op.params.role))
    |> step(:remove_member, &Repo.delete(&1.member))
  end

  defp find_member(task, user_id, role) do
    case Task.Member |> Repo.get_by(task_id: task.id, user_id: user_id, role: role) do
      %Task.Member{} = member -> {:ok, Repo.preload(member, [:user])}
      nil -> {:error, :not_found}
    end
  end
end
