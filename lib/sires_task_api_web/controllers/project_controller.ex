defmodule SiresTaskApiWeb.ProjectController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.{Repo, Project, ProjectPolicy}

  @preloads [:creator, :editor, members: :user]

  def index(conn, params) do
    with {:ok, query} <- Project.IndexQuery.call(conn.assigns.current_user, params: params) do
      {projects, pagination} = Pagination.paginate(query, params)
      conn |> render(projects: projects, pagination: pagination)
    end
  end

  plug SiresTaskApiWeb.Find,
       [schema: Project, assign: :project, preload: @preloads, policy: ProjectPolicy]
       when action == :show

  def show(conn, _params) do
    conn |> render(project: conn.assigns.project)
  end

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
