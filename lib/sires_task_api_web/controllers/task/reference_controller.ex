defmodule SiresTaskApiWeb.Task.ReferenceController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.Task

  def create(conn, params) do
    with {:ok, %{add_reference: reference}} <- Task.AddReference |> run(conn, params) do
      conn |> put_status(:created) |> render(:show, reference: reference)
    end
  end

  def delete(conn, params) do
    with {:ok, _} <- Task.RemoveReference |> run(conn, params) do
      conn |> json(%{result: "ok"})
    end
  end
end
