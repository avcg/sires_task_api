defmodule SiresTaskApi.ProjectPolicy do
  @behaviour Bodyguard.Policy
  import Ecto.Query
  alias SiresTaskApi.{Repo, User, Project}

  def authorize(:create_task, user, project), do: member?(user, project)
  def authorize(_, _, _), do: false

  defp member?(%User{id: user_id}, %Project{id: project_id}) do
    Project.Member
    |> where([m], m.user_id == ^user_id and m.project_id == ^project_id)
    |> Repo.one()
    |> case do
      %Project.Member{} -> true
      nil -> false
    end
  end
end
