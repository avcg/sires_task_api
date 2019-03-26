defmodule SiresTaskApiWeb.Task.MemberController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.Task

  def create(conn, params) do
    with {:ok, %{add_member: member}} <- Task.AddMember |> run(conn, params) do
      conn |> put_status(:created) |> render(:show, member: member)
    end
  end

  def delete(conn, params) do
    with {:ok, _} <- Task.RemoveMember |> run(conn, params) do
      conn |> json(%{result: "ok"})
    end
  end
end
