defmodule SiresTaskApi.Attachment do
  use Ecto.Schema

  schema "attachments" do
    field :file, :string
    timestamps(updated_at: false)

    belongs_to :task, SiresTaskApi.Task
    belongs_to :comment, SiresTaskApi.Task.Comment
  end
end
