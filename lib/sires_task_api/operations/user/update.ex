defmodule SiresTaskApi.User.Update do
  use SiresTaskApi.Operation,
    params: %{id!: :integer, user!: %{email: :string, password: :string, role: :string}}

  alias SiresTaskApi.{Repo, User, UserPolicy}

  def call(op) do
    op
    |> find(:user, schema: User)
    |> authorize(:user, policy: UserPolicy, action: :update)
    |> step(:update_user, fn %{user: user} ->
      user
      |> User.SharedHelpers.changeset(op.params.user, admin: op.context.user.role == "admin")
      |> Repo.update()
    end)
  end
end
