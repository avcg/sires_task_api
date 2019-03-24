defmodule SiresTaskApiWeb.Project.MemberController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.{Repo, Project}

  def create(conn, params) do
    with {:ok, %{add_member: member}} <- Project.AddMember |> run(conn, params) do
      conn |> put_status(:created) |> render(:show, member: Repo.preload(member, [:user]))
    end
  end
end
