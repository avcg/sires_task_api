defmodule SiresTaskApi.Task.AddComment do
  use SiresTaskApi.Operation,
    params: %{
      task_id!: :integer,
      comment!: %{text!: :string, attachments: [%{file: SiresTaskApi.Attachment}]}
    }

  alias SiresTaskApi.{Repo, Task, CommentPolicy}
  import Task.SharedHelpers

  def call(op) do
    op
    |> find(:task, schema: Task, id_path: [:task_id], preloads: [:project])
    |> authorize(:task, policy: CommentPolicy, action: :create)
    |> step(:add_comment, &add_comment(&1.task, op.params.comment, op.context.user))
    |> step(:upload_files, fn %{add_comment: comment} ->
      upload_comment_attachments(comment, op.params.comment[:attachments])
    end)
  end

  defp add_comment(task, params, author) do
    %Task.Comment{task: task, author: author}
    |> comment_changeset(params)
    |> Repo.insert()
  end
end
