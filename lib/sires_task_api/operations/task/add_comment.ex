defmodule SiresTaskApi.Task.AddComment do
  use SiresTaskApi.Operation, params: %{task_id!: :integer, comment!: %{text!: :string}}
  alias SiresTaskApi.{Repo, Task, CommentPolicy}

  def call(op) do
    op
    |> find(:task, schema: Task, id_path: [:task_id], preloads: [:project])
    |> authorize(:task, policy: CommentPolicy, action: :create)
    |> step(:add_comment, &add_comment(&1.task, op.params.comment, op.context.user))
  end

  defp add_comment(task, params, author) do
    %Task.Comment{task: task, author: author}
    |> Task.SharedHelpers.comment_changeset(params)
    |> Repo.insert()
  end
end
