defmodule SiresTaskApi.Project.Update do
  use SiresTaskApi.Operation, params: %{id!: :integer, project!: %{name!: :string}}
  alias SiresTaskApi.{Repo, Project, ProjectPolicy}

  def build(op) do
    op
    |> find(:project, schema: Project, preloads: [:editor])
    |> authorize(:project, policy: ProjectPolicy, action: :update)
    |> step(:update_project, &update_project(&1.project, op.params.project, op.context.user))
  end

  defp update_project(project, params, editor) do
    project
    |> Project.SharedHelpers.changeset(params)
    |> Ecto.Changeset.put_assoc(:editor, editor)
    |> Repo.update()
  end
end
