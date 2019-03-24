defmodule SiresTaskApi.Project.RemoveMember do
  use SiresTaskApi.Operation, params: %{project_id!: :integer, id!: :integer}
  alias SiresTaskApi.{Repo, Project, ProjectPolicy}

  def call(op) do
    op
    |> find(:project, schema: Project, id_path: [:project_id])
    |> authorize(:project, policy: ProjectPolicy, action: :update)
    |> step(:member, &Project.SharedHelpers.find_member(&1.project, op.params.id))
    |> step(:remove_member, &Repo.delete(&1.member))
  end
end
