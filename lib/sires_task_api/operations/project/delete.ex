defmodule SiresTaskApi.Project.Delete do
  use SiresTaskApi.Operation, params: %{id!: :integer}
  alias SiresTaskApi.{Repo, Project, ProjectPolicy}

  def call(op) do
    op
    |> find(:project, schema: Project)
    |> authorize(:project, policy: ProjectPolicy, action: :delete)
    |> step(:delete_project, &Repo.delete(&1.project))
  end
end
