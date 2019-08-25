defmodule SiresTaskApiWeb.UserView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApi.User.Avatar

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

  @fields ~w(id email active role inbox_project_id inserted_at updated_at first_name middle_name
             last_name position locale)a

  def user(user) do
    user
    |> Map.take(@fields)
    |> Map.put(:avatar, Avatar.url({user.avatar, user}, :thumb, signed: true))
  end
end
