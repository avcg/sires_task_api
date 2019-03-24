defmodule SiresTaskApi.User.Create do
  use SiresTaskApi.Operation,
    params: %{user!: %{email!: :string, password!: :string, role: :string}}

  alias SiresTaskApi.{Repo, User, Project}

  @inbox_project_name "Входящие"

  def call(op) do
    op
    |> step(:create_user, fn _ -> create_user(op.params.user) end)
  end

  defp create_user(params) do
    %User{}
    |> User.SharedHelpers.changeset(params)
    |> Ecto.Changeset.put_assoc(:inbox_project, %Project{name: @inbox_project_name})
    |> Repo.insert()
  end
end
