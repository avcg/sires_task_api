defmodule SiresTaskApi.Project.ChangeMemberRole do
  use SiresTaskApi.Operation,
    params: %{project_id!: :integer, id!: :integer, member!: %{role!: :string}}

  alias SiresTaskApi.{Repo, Project, ProjectPolicy}

  def build(op) do
    op
    |> find(:project, schema: Project, id_path: [:project_id])
    |> authorize(:project, policy: ProjectPolicy, action: :update)
    |> step(:member, &Project.SharedHelpers.find_member(&1.project, op.params.id))
    |> step(:change_member_role, &change_member_role(&1.member, op.params.member.role))
  end

  defp change_member_role(member, role) do
    member
    |> Ecto.Changeset.change(%{role: role})
    |> Ecto.Changeset.validate_inclusion(:role, ~w(admin regular guest))
    |> Repo.update()
  end
end
