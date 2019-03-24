defmodule SiresTaskApiWeb.ProjectView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.{UserView, Project.MemberView}

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
    |> Map.put(:members, Enum.map(project.members, &MemberView.member/1))
  end
end
