defmodule SiresTaskApiWeb.SignInController do
  use SiresTaskApiWeb, :controller
  import Ecto.Query
  alias SiresTaskApi.{Repo, User}

  def sign_in(conn, params) do
    with %{"email" => email, "password" => password} <- params,
         true <- is_binary(email) && is_binary(password),
         %User{} = user <- find_user(email),
         {:ok, _} <- Comeonin.Bcrypt.check_pass(user, password),
         {:ok, token, _claims} <- SiresTaskApiWeb.Guardian.encode_and_sign(user) do
      conn |> put_status(:created) |> render(user: user, jwt: token)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> put_view(SiresTaskApiWeb.ErrorView)
        |> render(:"401")
    end
  end

  defp find_user(email) do
    downcase_email = String.downcase(email)

    User
    |> where([u], fragment("LOWER(?) = ?", u.email, ^downcase_email))
    |> Repo.one()
  end
end
