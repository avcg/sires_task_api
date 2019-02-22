defmodule SiresTaskApiWeb.UserController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.User

  def create(conn, params) do
    with {:ok, %{create_user: user}} <- User.Create |> run(conn, params) do
      conn |> put_status(:created) |> render(:show, user: user)
    end
  end
end
