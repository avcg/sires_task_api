defmodule SiresTaskApi.Task.Attachment.Version do
  defmodule Definition do
    use Arc.Definition
    use Arc.Ecto.Definition

    def storage_dir(_, {_, %{id: id} = vsn}) when not is_nil(id) do
      "uploads/tasks/#{vsn.attachment.task_id}/attachments/#{vsn.attachment_id}/versions/#{vsn.id}"
    end
  end

  use Ecto.Schema
  use Arc.Ecto.Schema

  schema "task_attachment_versions" do
    field :file, Definition.Type
    timestamps(updated_at: false)

    belongs_to :attachment, SiresTaskApi.Task.Attachment
  end
end
