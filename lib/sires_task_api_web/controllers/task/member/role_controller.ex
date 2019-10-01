defmodule SiresTaskApiWeb.Task.Member.RoleController do
  use SiresTaskApiWeb, :controller

  alias SiresTaskApi.Task
  alias SiresTaskApiWeb.Task.MemberView

  def update(conn, params) do
    with {:ok, %{members: members}} <- Task.SetMembersByRole |> run(conn, params) do
      conn |> put_view(MemberView) |> render(:index, members: members)
    end
  end
end
