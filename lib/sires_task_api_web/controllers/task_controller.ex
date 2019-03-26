defmodule SiresTaskApiWeb.TaskController do
  use SiresTaskApiWeb, :controller
  import Ecto.Query
  alias SiresTaskApi.{Repo, Task, TaskPolicy}

  plug SiresTaskApiWeb.Find,
       [schema: Task, assign: :task, policy: TaskPolicy, preload: &__MODULE__.preloads/0]
       when action == :show

  def show(conn, _params) do
    conn |> render(task: Repo.preload(conn.assigns.task, preloads()))
  end

  def create(conn, params) do
    with {:ok, %{create_task: task}} <- Task.Create |> run(conn, params) do
      conn |> put_status(:created) |> render(:show, task: Repo.preload(task, preloads()))
    end
  end

  def update(conn, params) do
    with {:ok, %{update_task: task}} <- Task.Update |> run(conn, params) do
      conn |> render(:show, task: Repo.preload(task, preloads()))
    end
  end

  def mark_done(conn, %{"task_id" => id}) do
    with {:ok, %{update_task: task}} <- Task.ToggleDone |> run(conn, %{id: id, done: true}) do
      conn |> render(:show, task: Repo.preload(task, preloads()))
    end
  end

  def mark_undone(conn, %{"task_id" => id}) do
    with {:ok, %{update_task: task}} <- Task.ToggleDone |> run(conn, %{id: id, done: false}) do
      conn |> render(:show, task: Repo.preload(task, preloads()))
    end
  end

  def delete(conn, params) do
    with {:ok, _} <- Task.Delete |> run(conn, params) do
      conn |> json(%{result: "ok"})
    end
  end

  def preloads do
    [
      :project,
      :creator,
      :editor,
      :attachments,
      :tags,
      members: :user,
      comments: {Task.Comment |> order_by(desc: :inserted_at), [:author]},
      child_references: :parent_task,
      parent_references: :child_task
    ]
  end
end
