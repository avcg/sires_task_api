defmodule SiresTaskApiWeb.TagController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.{Repo, Tag}

  @preloads [:creator, :editor]

  def index(conn, params) do
    with {:ok, query} <- Tag.IndexQuery.call(conn.assigns.current_user, params: params) do
      {tags, pagination} = Pagination.paginate(query, params)
      conn |> render(tags: tags, pagination: pagination)
    end
  end

  def create(conn, params) do
    with {:ok, %{create_tag: tag}} <- Tag.Create |> run(conn, params) do
      conn |> put_status(:created) |> render(:show, tag: Repo.preload(tag, @preloads))
    end
  end

  def update(conn, params) do
    with {:ok, %{update_tag: tag}} <- Tag.Update |> run(conn, params) do
      conn |> render(:show, tag: Repo.preload(tag, @preloads))
    end
  end

  def delete(conn, params) do
    with {:ok, _} <- Tag.Delete |> run(conn, params) do
      conn |> json(%{result: "ok"})
    end
  end
end
