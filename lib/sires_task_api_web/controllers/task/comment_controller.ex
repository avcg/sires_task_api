defmodule SiresTaskApiWeb.Task.CommentController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.{Repo, Task}

  @preloads [:author, attachments: :comment]

  def create(conn, params) do
    with {:ok, %{add_comment: comment}} <- Task.AddComment |> run(conn, params) do
      conn
      |> put_status(:created)
      |> render(:show, comment: Repo.preload(comment, @preloads, force: true))
    end
  end

  def update(conn, params) do
    with {:ok, %{change_comment: comment}} <- Task.ChangeComment |> run(conn, params) do
      conn |> render(:show, comment: Repo.preload(comment, @preloads, force: true))
    end
  end

  def delete(conn, params) do
    with {:ok, _} <- Task.RemoveComment |> run(conn, params) do
      conn |> json(%{result: "ok"})
    end
  end
end
