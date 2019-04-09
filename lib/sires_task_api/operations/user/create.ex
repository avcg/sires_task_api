defmodule SiresTaskApi.User.Create do
  use SiresTaskApi.Operation,
    params: %{user!: %{email!: :string, password!: :string, role: :string}}

  alias SiresTaskApi.{Repo, User, Project}

  @inbox_project_name "Входящие"

  def call(op) do
    op
    |> step(:create_project, fn _ -> create_project() end)
    |> step(:create_user, &create_user(op.params.user, &1.create_project))
    |> step(:create_member, &create_member(&1.create_user, &1.create_project))
  end

  defp create_project do
    %Project{name: @inbox_project_name} |> Repo.insert()
  end

  defp create_user(params, project) do
    %User{inbox_project: project}
    |> User.SharedHelpers.changeset(params)
    |> Repo.insert()
  end

  defp create_member(user, project) do
    %Project.Member{user: user, project: project, role: "admin"}
    |> Repo.insert()
  end
end
