defmodule SiresTaskApiWeb.UserController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.User

  def create(conn, params) do
    with {:ok, %{create_user: user}} <- User.Create |> run(conn, params),
         {:ok, token, _claims} <- SiresTaskApiWeb.Guardian.encode_and_sign(user) do
      conn |> put_status(:created) |> render(user: user, jwt: token)
    end
  end

  def update(conn, params) do
    with {:ok, %{update_user: user}} <- User.Update |> run(conn, params) do
      conn |> render(:show, user: user)
    end
  end

  def deactivate(conn, %{"user_id" => id}) do
    with {:ok, %{update_user: user}} <- User.ToggleActive |> run(conn, %{id: id, active: false}) do
      conn |> render(:show, user: user)
    end
  end

  def activate(conn, %{"user_id" => id}) do
    with {:ok, %{update_user: user}} <- User.ToggleActive |> run(conn, %{id: id, active: true}) do
      conn |> render(:show, user: user)
    end
  end
end
