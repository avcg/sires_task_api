defmodule SiresTaskApi.Task.Member do
  use Ecto.Schema

  @primary_key false
  schema "task_members" do
    field :role, :string, default: "assignee"
    timestamps()

    belongs_to :task, SiresTaskApi.Task, primary_key: true
    belongs_to :user, SiresTaskApi.User, primary_key: true
  end
end
