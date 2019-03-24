defmodule SiresTaskApiWeb.ProjectController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.Project

  def create(conn, params) do
    with {:ok, %{create_project: project}} <- Project.Create |> run(conn, params) do
      project = project |> SiresTaskApi.Repo.preload([:creator, :editor, members: :user])
      conn |> put_status(:created) |> render(:show, project: project)
    end
  end
end
