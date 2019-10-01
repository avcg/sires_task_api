defmodule SiresTaskApi.Task.Create do
  use SiresTaskApi.Operation,
    params: %{
      task!: %{
        project_id!: :integer,
        name!: :string,
        description: :string,
        start_time: :utc_datetime,
        finish_time: :utc_datetime,
        tag_ids: {:array, :integer},
        attachments: [%{file: SiresTaskApi.Attachment}]
      }
    }

  alias SiresTaskApi.{Repo, Task, Project, TaskPolicy}
  import Task.SharedHelpers

  def build(op) do
    op
    |> find(:project, schema: Project, id_path: [:task, :project_id])
    |> authorize(:project, policy: TaskPolicy, action: :create)
    |> step(:tags, fn _ -> {:ok, find_tags(op.params.task[:tag_ids])} end)
    |> step(:create_task, &create_task(op.params.task, &1.project, &1.tags, op.context.user))
    |> step(:upload_files, &upload_attachments(&1.create_task, op.params.task[:attachments]))
  end

  defp create_task(params, project, tags, creator) do
    %Task{project: project, creator: creator, editor: creator}
    |> changeset(params, tags)
    |> Ecto.Changeset.validate_required([:name])
    |> Ecto.Changeset.put_assoc(:members, [%Task.Member{user: creator, role: "assignator"}])
    |> Repo.insert()
  end
end
