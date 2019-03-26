defmodule SiresTaskApi.Task do
  use Ecto.Schema
  import Ecto.Query
  alias SiresTaskApi.{User, Project, Attachment, Tag}
  alias __MODULE__.{Member, Reference, Comment}

  schema "tasks" do
    field :name, :string
    field :description, :string
    field :start_time, :utc_datetime
    field :finish_time, :utc_datetime
    field :done, :boolean, default: false
    timestamps()

    belongs_to :project, Project
    belongs_to :creator, User
    belongs_to :editor, User

    has_many :members, Member
    has_many :parent_references, Reference, foreign_key: :parent_task_id
    has_many :children_tasks, through: [:parent_references, :children_task]
    has_many :child_references, Reference, foreign_key: :child_task_id
    has_many :parent_tasks, through: [:child_references, :parent_task]
    has_many :comments, Comment
    has_many :attachments, Attachment
    many_to_many :tags, Tag, join_through: "task_tags", on_replace: :delete
  end

  @behaviour Bodyguard.Schema

  def scope(query, %User{role: "admin"}, _), do: query

  def scope(query, %User{id: user_id}, _) do
    query
    |> join(:inner, [t], p in assoc(t, :project))
    |> join(:inner, [t, p], pm in assoc(p, :members))
    |> where([t, p, pm], pm.user_id == ^user_id)
  end
end
