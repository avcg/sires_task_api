defmodule SiresTaskApi.Project.AddMember do
  use SiresTaskApi.Operation,
    params: %{project_id!: :integer, member!: %{user_id!: :integer, role: :string}}

  alias SiresTaskApi.{Repo, User, Project, ProjectPolicy}

  def build(op) do
    op
    |> find(:project, schema: Project, id_path: [:project_id])
    |> authorize(:project, policy: ProjectPolicy, action: :update)
    |> find(:user, schema: User, id_path: [:member, :user_id])
    |> step(:add_member, &add_member(&1.project, &1.user, op.params.member[:role]))
  end

  defp add_member(project, user, role) do
    %Project.Member{project: project, user: user}
    |> Ecto.Changeset.change(%{role: role || "regular"})
    |> Ecto.Changeset.validate_inclusion(:role, ~w(admin regular guest))
    |> Ecto.Changeset.unique_constraint(:user, name: :project_members_project_id_user_id_index)
    |> Repo.insert()
  end
end
