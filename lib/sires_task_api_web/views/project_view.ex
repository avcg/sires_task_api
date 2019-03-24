defmodule SiresTaskApiWeb.ProjectView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.UserView

  def render("index.json", %{projects: projects, pagination: pagination}) do
    %{projects: Enum.map(projects, &project/1), total_count: pagination.total_count}
  end

  def render("show.json", %{project: project}) do
    %{project: project(project, :full)}
  end

  def project(project), do: project(project, :short)

  def project(project, :short) do
    project
    |> Map.take([:id, :name, :inserted_at, :updated_at])
  end

  def project(project, :full) do
    project
    |> project(:short)
    |> Map.put(:creator, project.creator && UserView.user(project.creator))
    |> Map.put(:editor, project.editor && UserView.user(project.editor))
    |> Map.put(:members, Enum.map(project.members, &member/1))
  end

  def member(member) do
    member
    |> Map.take([:role, :inserted_at])
    |> Map.put(:user, UserView.user(member.user))
  end
end
