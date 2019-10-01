defmodule SiresTaskApi.Task.SetMembersByRole do
  use SiresTaskApi.Operation,
    params: %{task_id!: :integer, role!: :string, user_ids!: [:integer]}

  import Ecto.Query
  alias SiresTaskApi.{Repo, User, Task, TaskPolicy, ProjectPolicy}

  @roles ~w(assignator responsible co-responsible observer)

  def validate_params(changeset) do
    changeset |> Ecto.Changeset.validate_inclusion(:role, @roles)
  end

  def build(op) do
    op
    |> find(:task, schema: Task, id_path: [:task_id], preloads: [:project])
    |> authorize(:task, policy: TaskPolicy, action: :update)
    |> step(:find_users, fn _ -> find_users(op.params.user_ids) end)
    |> step(:ensure_project_members, &ensure_project_members(&1.find_users, &1.task.project))
    |> step(:delete_members, &delete_members(&1.task, op.params.role, op.params.user_ids))
    |> step(:insert_members, &insert_members(&1.task, op.params.role, op.params.user_ids))
    |> step(:members, &members(&1.task, op.params.role))
  end

  defp find_users(ids) do
    users = User |> where([u], u.id in ^ids) |> Repo.all()
    if length(users) == length(ids), do: {:ok, users}, else: {:error, :not_found}
  end

  defp ensure_project_members(users, project) do
    if users |> Enum.all?(&ProjectPolicy.member?(&1, project, ~w(admin regular))) do
      {:ok, true}
    else
      {:error, :user_is_not_a_regular_project_member}
    end
  end

  defp delete_members(%Task{id: task_id}, role, user_ids) do
    Task.Member
    |> where([m], m.task_id == ^task_id and (m.role == ^role or m.user_id in ^user_ids))
    |> Repo.delete_all()

    {:ok, true}
  end

  defp insert_members(%Task{id: task_id}, role, user_ids) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    entries =
      user_ids |> Enum.map(&%{task_id: task_id, user_id: &1, role: role, inserted_at: now})

    Task.Member |> Repo.insert_all(entries)
    {:ok, true}
  end

  defp members(%Task{id: task_id}, role) do
    members =
      Task.Member
      |> where([m], m.task_id == ^task_id and m.role == ^role)
      |> preload([:user])
      |> Repo.all()

    {:ok, members}
  end
end
