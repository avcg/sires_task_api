defmodule SiresTaskApi.Task.ChangeComment do
  use SiresTaskApi.Operation,
    params: %{
      task_id!: :integer,
      id!: :integer,
      comment!: %{text!: :string, attachments: [%{file: SiresTaskApi.Attachment}]}
    }

  alias SiresTaskApi.{Repo, Task, CommentPolicy}
  import Task.SharedHelpers

  def build(op) do
    op
    |> find(:comment, schema: Task.Comment, preloads: [:attachments, task: :project])
    |> step(:ensure_task_id, &ensure_task_id(&1.comment, op.params.task_id))
    |> authorize(:comment, policy: CommentPolicy, action: :update)
    |> step(:change_comment, &change_comment(&1.comment, op.params.comment))
    |> step(:upload_files, fn %{change_comment: comment} ->
      upload_comment_attachments(comment, op.params.comment[:attachments])
    end)
  end

  defp change_comment(comment, params) do
    comment
    |> comment_changeset(params)
    |> Repo.update()
  end
end
