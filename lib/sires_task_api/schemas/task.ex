defmodule SiresTaskApi.Task do
  use Ecto.Schema

  schema "tasks" do
    field :name, :string
    field :description, :string
    field :start_time, :utc_datetime
    field :finish_time, :utc_datetime
    field :done, :boolean, default: false
    timestamps()

    belongs_to :project, SiresTaskApi.Project
    belongs_to :creator, SiresTaskApi.User
    belongs_to :editor, SiresTaskApi.User

    has_many :members, __MODULE__.Member
    has_many :parent_references, __MODULE__.Reference, foreign_key: :parent_task_id
    has_many :children_tasks, through: [:parent_references, :children_task]
    has_many :child_references, __MODULE__.Reference, foreign_key: :child_task_id
    has_many :parent_tasks, through: [:child_references, :parent_task]
    has_many :comments, __MODULE__.Comment
    has_many :attachments, SiresTaskApi.Attachment
    many_to_many :tags, SiresTaskApi.Tag, join_through: "task_tags"
  end
end
