defmodule SiresTaskApi.User.Create do
  use SiresTaskApi.Operation,
    params: %{user!: %{email!: :string, password!: :string, role: :string}}

  alias SiresTaskApi.{Repo, User}

  def call(op) do
    step(op, :create_user, fn _ ->
      %User{}
      |> User.SharedHelpers.changeset(op.params.user)
      |> Repo.insert()
    end)
  end
end
