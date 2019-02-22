defmodule SiresTaskApi.Task.Reference do
  use Ecto.Schema

  @primary_key false
  schema "task_references" do
    field :reference_type, :string, default: "subtask"
    timestamps(updated_at: false)

    belongs_to :parent_task, SiresTaskApi.Task, primary_key: true
    belongs_to :child_task, SiresTaskApi.Task, primary_key: true
  end
end
