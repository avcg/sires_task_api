defmodule SiresTaskApi.Task.Create do
  use SiresTaskApi.Operation,
    params: %{
      task!: %{
        project_id!: :integer,
        name!: :string,
        description: :string,
        start_time: :utc_datetime,
        finish_time: :utc_datetime,
        tag_ids: {:array, :integer}
      }
    }

  alias SiresTaskApi.{Repo, Task, Project, TaskPolicy}

  def call(op) do
    op
    |> find(:project, schema: Project, id_path: [:task, :project_id])
    |> authorize(:project, policy: TaskPolicy, action: :create)
    |> step(:tags, fn _ -> {:ok, Task.SharedHelpers.find_tags(op.params.task[:tag_ids])} end)
    |> step(:create_task, &create_task(op.params.task, &1.tags, op.context.user))
  end

  defp create_task(params, tags, creator) do
    %Task{project_id: params.project_id, creator: creator, editor: creator}
    |> Task.SharedHelpers.changeset(params, tags)
    |> Ecto.Changeset.validate_required([:name])
    |> Ecto.Changeset.put_assoc(:members, [%Task.Member{user: creator, role: "assignor"}])
    |> Repo.insert()
  end
end
