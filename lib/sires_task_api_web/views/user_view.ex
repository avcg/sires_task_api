defmodule SiresTaskApiWeb.UserView do
  use SiresTaskApiWeb, :view

  def render("index.json", %{users: users, pagination: pagination}) do
    %{users: Enum.map(users, &user/1), total_count: pagination.total_count}
  end

  def render("show.json", %{user: user}) do
    %{user: user(user)}
  end

  # We also return JWT to allow to act as the newly registered user without forcing him to sign in.
  def render("create.json", %{user: user, jwt: jwt}) do
    "show.json"
    |> render(%{user: user})
    |> Map.put(:jwt, jwt)
  end

  def user(user) do
    user
    |> Map.take([:id, :email, :active, :role, :inbox_project_id, :inserted_at, :updated_at])
  end
end
