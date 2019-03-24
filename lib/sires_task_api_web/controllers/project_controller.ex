defmodule SiresTaskApiWeb.ProjectController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.{Repo, Project}

  @preloads [:creator, :editor, members: :user]

  def create(conn, params) do
    with {:ok, %{create_project: project}} <- Project.Create |> run(conn, params) do
      conn |> put_status(:created) |> render(:show, project: Repo.preload(project, @preloads))
    end
  end

  def update(conn, params) do
    with {:ok, %{update_project: project}} <- Project.Update |> run(conn, params) do
      conn |> render(:show, project: Repo.preload(project, @preloads))
    end
  end
end
