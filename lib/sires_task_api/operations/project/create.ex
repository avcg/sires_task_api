defmodule SiresTaskApi.Project.Create do
  use SiresTaskApi.Operation, params: %{project!: %{name!: :string}}
  import Ecto.Changeset
  alias SiresTaskApi.{Repo, Project}

  def call(op) do
    op
    |> step(:create_project, fn _ -> create_project(op.params.project, op.context.user) end)
  end

  defp create_project(params, creator) do
    %Project{}
    |> changeset(params)
    |> put_assoc(:creator, creator)
    |> put_assoc(:editor, creator)
    |> put_assoc(:members, [%Project.Member{user: creator, role: "admin"}])
    |> Repo.insert()
  end

  defp changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
  end
end
