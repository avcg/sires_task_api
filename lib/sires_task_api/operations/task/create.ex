defmodule SiresTaskApi.Task.Create do
  use SiresTaskApi.Operation, params: %{
    project_id!: :integer,
    task!: %{name!: :string}
  }

  import Ecto.Changeset
  alias SiresTaskApi.{Repo, Task, Project}

  def call(op) do
    op
    |> find(:project, schema: Project, id_path: [:project])
    |> authorize(:project, policy: ProjectPolicy, action: :create_task)
    |> step(:create_task, fn _ -> create_task(op.params.task) end)
  end

  defp create_task(params) do
    %Task{}
    |> changeset(params)
    |> Repo.insert()
  end

  defp changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
  end
end
