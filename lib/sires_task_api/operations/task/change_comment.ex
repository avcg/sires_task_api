defmodule SiresTaskApi.Task.ChangeComment do
  use SiresTaskApi.Operation,
    params: %{task_id!: :integer, id!: :integer, comment!: %{text!: :string}}

  alias SiresTaskApi.{Repo, Task, CommentPolicy}

  def call(op) do
    op
    |> find(:comment, schema: Task.Comment, preloads: [task: :project])
    |> step(:ensure_task_id, &Task.SharedHelpers.ensure_task_id(&1.comment, op.params.task_id))
    |> authorize(:comment, policy: CommentPolicy, action: :update)
    |> step(:change_comment, &change_comment(&1.comment, op.params.comment))
  end

  defp change_comment(comment, params) do
    comment
    |> Task.SharedHelpers.comment_changeset(params)
    |> Repo.update()
  end
end
