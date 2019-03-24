defmodule SiresTaskApiWeb.CurrentUserController do
  use SiresTaskApiWeb, :controller

  def show(conn, _params) do
    conn
    |> put_view(SiresTaskApiWeb.UserView)
    |> render(user: conn.assigns.current_user)
  end
end
