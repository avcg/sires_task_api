defmodule SiresTaskApiWeb.SignInView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.UserView

  def render("sign_in.json", %{user: user, jwt: token}) do
    %{jwt: token, user: UserView.user(user)}
  end
end
