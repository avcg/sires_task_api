defmodule SiresTaskApiWeb.UserView do
  use SiresTaskApiWeb, :view

  def render("show.json", %{user: user}) do
    %{user: user(user)}
  end

  def user(user) do
    user
    |> Map.take([:id, :email, :inserted_at, :updated_at])
  end
end
