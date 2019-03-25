defmodule SiresTaskApi.TaskPolicy do
  @behaviour Bodyguard.Policy

  import Ecto.Query
  alias SiresTaskApi.{Repo, User, Task, ProjectPolicy}

  def authorize(_, %User{role: "admin"}, _), do: true
  def authorize(:create, user, project), do: ProjectPolicy.authorize(:create_task, user, project)

  def authorize(:update, user, task) do
    member?(user, task, ~w(assignor)) || ProjectPolicy.member?(user, task.project, ~w(admin))
  end

  def authorize(_, _, _) do
    false
  end

  defp member?(%User{id: user_id}, %Task{id: task_id}, roles) do
    Task.Member
    |> where([m], m.user_id == ^user_id and m.task_id == ^task_id and m.role in ^roles)
    |> limit(1)
    |> Repo.aggregate(:count, :user_id)
    |> Kernel.==(1)
  end
end
