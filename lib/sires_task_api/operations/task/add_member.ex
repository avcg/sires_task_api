defmodule SiresTaskApi.Task.AddMember do
  use SiresTaskApi.Operation,
    params: %{task_id!: :integer, member!: %{user_id!: :integer, role!: :string}}

  alias SiresTaskApi.{Repo, User, Task, TaskPolicy, ProjectPolicy}

  def build(op) do
    op
    |> find(:task, schema: Task, id_path: [:task_id], preloads: [:project])
    |> authorize(:task, policy: TaskPolicy, action: :update)
    |> find(:user, schema: User, id_path: [:member, :user_id])
    |> step(:ensure_project_member, &ensure_project_member(&1.user, &1.task.project))
    |> step(:add_member, &add_member(&1.task, &1.user, op.params.member[:role]))
  end

  defp ensure_project_member(user, project) do
    if ProjectPolicy.member?(user, project, ~w(admin regular)) do
      {:ok, true}
    else
      {:error, :user_is_not_a_regular_project_member}
    end
  end

  defp add_member(task, user, role) do
    %Task.Member{task: task, user: user}
    |> Ecto.Changeset.change(%{role: role})
    |> Ecto.Changeset.validate_inclusion(:role, ~w(assignator responsible co-responsible observer))
    |> Ecto.Changeset.unique_constraint(:role, name: :task_members_pkey)
    |> Repo.insert()
  end
end
