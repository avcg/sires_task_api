defmodule SiresTaskApiWeb.Project.MemberController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.{Repo, Project}

  def create(conn, params) do
    with {:ok, %{add_member: member}} <- Project.AddMember |> run(conn, params) do
      conn |> put_status(:created) |> render(:show, member: Repo.preload(member, [:user]))
    end
  end

  def update(conn, params) do
    with {:ok, %{change_member_role: member}} <- Project.ChangeMemberRole |> run(conn, params) do
      conn |> render(:show, member: Repo.preload(member, [:user]))
    end
  end

  def delete(conn, params) do
    with {:ok, _} <- Project.RemoveMember |> run(conn, params) do
      conn |> json(%{result: "ok"})
    end
  end
end
