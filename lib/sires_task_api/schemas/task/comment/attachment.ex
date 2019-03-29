defmodule SiresTaskApi.Task.Comment.Attachment do
  defmodule Definition do
    use Arc.Definition
    use Arc.Ecto.Definition

    def storage_dir(_, {_, %{id: id} = at}) when not is_nil(id) do
      "uploads/tasks/#{at.comment.task_id}/comments/#{at.comment_id}/attachments/#{at.id}"
    end
  end

  use Ecto.Schema
  use Arc.Ecto.Schema

  schema "task_comment_attachments" do
    field :file, Definition.Type
    belongs_to :comment, SiresTaskApi.Task.Comment
  end
end
