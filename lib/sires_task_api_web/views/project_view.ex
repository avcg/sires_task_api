defmodule SiresTaskApiWeb.ProjectView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.UserView

  def render("show.json", %{project: project}) do
    %{project: project(project)}
  end

  def project(project) do
    project
    |> Map.take([:name, :inserted_at, :updated_at])
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
