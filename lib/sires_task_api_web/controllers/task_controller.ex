defmodule SiresTaskApiWeb.TaskController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.{Repo, Task}

  @preloads [
    :project,
    :creator,
    :editor,
    :attachments,
    :tags,
    members: :user,
    comments: :author,
    child_references: :parent_task,
    parent_references: :child_task
  ]

  def create(conn, params) do
    with {:ok, %{create_task: task}} <- Task.Create |> run(conn, params) do
      conn |> put_status(:created) |> render(:show, task: Repo.preload(task, @preloads))
    end
  end

  def update(conn, params) do
    with {:ok, %{update_task: task}} <- Task.Update |> run(conn, params) do
      conn |> render(:show, task: Repo.preload(task, @preloads))
    end
  end
end
