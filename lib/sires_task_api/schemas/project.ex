defmodule SiresTaskApi.Project do
  use Ecto.Schema

  schema "projects" do
    field :name, :string
    timestamps()

    belongs_to :creator, SiresTaskApi.User
    belongs_to :editor, SiresTaskApi.User

    has_one :inbox_user, SiresTaskApi.User, foreign_key: :inbox_project_id
    has_many :members, __MODULE__.Member
    has_many :tasks, SiresTaskApi.Task
  end
end
