defmodule SiresTaskApi.Task.RemoveComment do
  use SiresTaskApi.Operation, params: %{task_id!: :integer, id!: :integer}
  alias SiresTaskApi.{Repo, Task, CommentPolicy}

  def build(op) do
    op
    |> find(:comment, schema: Task.Comment, preloads: [task: :project])
    |> step(:ensure_task_id, &Task.SharedHelpers.ensure_task_id(&1.comment, op.params.task_id))
    |> authorize(:comment, policy: CommentPolicy, action: :delete)
    |> step(:remove_comment, &Repo.delete(&1.comment))
  end
end
