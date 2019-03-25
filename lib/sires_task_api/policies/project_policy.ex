defmodule SiresTaskApi.ProjectPolicy do
  @behaviour Bodyguard.Policy
  import Ecto.Query
  alias SiresTaskApi.{Repo, User, Project}

  def authorize(:delete, user, project), do: authorize_delete(user, project)
  def authorize(_, %User{role: "admin"}, _), do: true
  def authorize(:show, user, project), do: member?(user, project, ~w(admin regular guest))
  def authorize(:update, user, project), do: member?(user, project, ~w(admin))
  def authorize(:create_task, user, project), do: member?(user, project, ~w(admin regular))
  def authorize(_, _, _), do: false

  def member?(%User{id: user_id}, %Project{id: project_id}, roles) do
    Project.Member
    |> where([m], m.user_id == ^user_id and m.project_id == ^project_id and m.role in ^roles)
    |> limit(1)
    |> Repo.aggregate(:count, :user_id)
    |> Kernel.==(1)
  end

  defp authorize_delete(user, project) do
    project = project |> Repo.preload(:inbox_user)

    # Even global admin can't delete someone's inbox project.
    # For non-inbox projects deletion is avaialable for project admins and global admins.
    cond do
      project.inbox_user != nil -> false
      user.role == "admin" -> true
      member?(user, project, ~w(admin)) -> true
      true -> false
    end
  end
end
