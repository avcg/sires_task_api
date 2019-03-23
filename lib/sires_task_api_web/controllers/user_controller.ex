defmodule SiresTaskApiWeb.UserController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.User

  def create(conn, params) do
    with {:ok, %{create_user: user}} <- User.Create |> run(conn, params),
         {:ok, token, _claims} <- SiresTaskApiWeb.Guardian.encode_and_sign(user) do
      conn |> put_status(:created) |> render(user: user, jwt: token)
    end
  end
end
