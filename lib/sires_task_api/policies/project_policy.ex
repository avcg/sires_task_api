defmodule SiresTaskApi.ProjectPolicy do
  @behaviour Bodyguard.Policy
  import Ecto.Query
  alias SiresTaskApi.{Repo, User, Project}

  def authorize(_, %User{role: "admin"}, _), do: true
  def authorize(:show, user, project), do: member?(user, project, ~w(admin regular guest))
  def authorize(:update, user, project), do: member?(user, project, ~w(admin))
  def authorize(:create_task, user, project), do: member?(user, project, ~w(admin regular))
  def authorize(_, _, _), do: false

  defp member?(%User{id: user_id}, %Project{id: project_id}, roles) do
    Project.Member
    |> where([m], m.user_id == ^user_id and m.project_id == ^project_id and m.role in ^roles)
    |> Repo.one()
    |> case do
      %Project.Member{} -> true
      nil -> false
    end
  end
end
