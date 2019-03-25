defmodule SiresTaskApi.Task.Create do
  use SiresTaskApi.Operation,
    params: %{
      task!: %{
        project_id!: :integer,
        name!: :string,
        description: :string,
        start_time: :utc_datetime,
        finish_time: :utc_datetime
      }
    }

  import Ecto.Changeset
  alias SiresTaskApi.{Repo, Task, Project, ProjectPolicy}

  def call(op) do
    op
    |> find(:project, schema: Project, id_path: [:task, :project_id])
    |> authorize(:project, policy: ProjectPolicy, action: :create_task)
    |> step(:create_task, fn _ -> create_task(op.params.task, op.context.user) end)
  end

  defp create_task(params, creator) do
    %Task{project_id: params.project_id, creator: creator, editor: creator}
    |> changeset(params)
    |> Repo.insert()
  end

  defp changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name, :description, :start_time, :finish_time])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
    |> validate_start_and_finish_times()
  end

  defp validate_start_and_finish_times(changeset) do
    start = changeset |> get_field(:start_time)
    finish = changeset |> get_field(:finish_time)

    if start && finish && DateTime.compare(start, finish) == :gt do
      changeset |> add_error(:finish_time, "can't be earlier than start time")
    else
      changeset
    end
  end
end
