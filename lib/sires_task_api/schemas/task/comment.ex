defmodule SiresTaskApi.Task.Comment do
  use Ecto.Schema

  schema "task_comments" do
    field :text, :string
    timestamps()

    belongs_to :task, SiresTaskApi.Task
    belongs_to :author, SiresTaskApi.User
  end
end
