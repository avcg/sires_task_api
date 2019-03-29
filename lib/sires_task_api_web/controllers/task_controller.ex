defmodule SiresTaskApiWeb.TaskController do
  use SiresTaskApiWeb, :controller
  import Ecto.Query
  alias SiresTaskApi.{Repo, Task, TaskPolicy}

  def index(conn, params) do
    with {:ok, query} <- Task.IndexQuery.call(conn.assigns.current_user, params: params) do
      {tasks, pagination} = Pagination.paginate(query, params)
      conn |> render(tasks: tasks, pagination: pagination)
    end
  end

  plug SiresTaskApiWeb.Find,
       [schema: Task, assign: :task, policy: TaskPolicy, preload: &__MODULE__.preloads/0]
       when action == :show

  def show(conn, _params) do
    conn |> render(task: Repo.preload(conn.assigns.task, preloads()))
  end

  def create(conn, params) do
    with {:ok, %{create_task: task}} <- Task.Create |> run(conn, params) do
      conn
      |> put_status(:created)
      |> render(:show, task: Repo.preload(task, preloads(), force: true))
    end
  end

  def update(conn, params) do
    with {:ok, %{update_task: task}} <- Task.Update |> run(conn, params) do
      conn |> render(:show, task: Repo.preload(task, preloads(), force: true))
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
    last_attachment_versions_query =
      Task.Attachment.Version
      |> order_by(desc: :inserted_at)
      |> distinct(:attachment_id)

    comments_query =
      Task.Comment
      |> order_by(desc: :inserted_at)

    [
      :project,
      :creator,
      :editor,
      :tags,
      members: :user,
      attachments: [versions: {last_attachment_versions_query, [:attachment]}],
      comments: {comments_query, [:author, :attachments]},
      child_references: :parent_task,
      parent_references: :child_task
    ]
  end
end
