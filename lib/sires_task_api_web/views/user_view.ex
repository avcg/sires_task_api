defmodule SiresTaskApiWeb.UserView do
  use SiresTaskApiWeb, :view

  def render("create.json", %{user: user, jwt: jwt}) do
    "show.json"
    |> render(%{user: user})
    |> Map.put(:jwt, jwt)
  end

  def render("show.json", %{user: user}) do
    %{user: user(user)}
  end

  def user(user) do
    user
    |> Map.take([:id, :email, :inserted_at, :updated_at])
  end
end
