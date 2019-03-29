defmodule SiresTaskApi.Task.Attachment do
  use Ecto.Schema

  schema "task_attachments" do
    belongs_to :task, SiresTaskApi.Task

    has_many :versions, __MODULE__.Version
  end
end
