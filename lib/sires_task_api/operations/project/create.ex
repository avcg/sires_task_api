defmodule SiresTaskApi.Project.Create do
  use SiresTaskApi.Operation, params: %{project!: %{name!: :string}}
  alias SiresTaskApi.{Repo, Project}

  def call(op) do
    op
    |> step(:create_project, fn _ -> create_project(op.params.project, op.context.user) end)
  end

  defp create_project(params, creator) do
    %Project{}
    |> Project.SharedHelpers.changeset(params)
    |> Ecto.Changeset.put_assoc(:creator, creator)
    |> Ecto.Changeset.put_assoc(:editor, creator)
    |> Ecto.Changeset.put_assoc(:members, [%Project.Member{user: creator, role: "admin"}])
    |> Repo.insert()
  end
end
