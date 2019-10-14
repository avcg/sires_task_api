defmodule SiresTaskApiWeb.CurrentUserView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.UserView

  def render("show.json", %{user: user, ws_token: ws_token}) do
    %{user: UserView.user(user), ws_token: ws_token}
  end
end
