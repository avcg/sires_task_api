defmodule SiresTaskApiWeb.CurrentUserController do
  use SiresTaskApiWeb, :controller

  def show(conn, _params) do
    ws_token = Phoenix.Token.sign(conn, "user", conn.assigns.current_user.id)

    conn
    |> put_view(SiresTaskApiWeb.CurrentUserView)
    |> render(user: conn.assigns.current_user, ws_token: ws_token)
  end
end
