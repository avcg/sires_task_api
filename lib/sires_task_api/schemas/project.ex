defmodule SiresTaskApi.Project do
  use Ecto.Schema
  import Ecto.Query
  alias SiresTaskApi.{User, Task}

  schema "projects" do
    field :name, :string
    timestamps()

    belongs_to :creator, User
    belongs_to :editor, User

    has_one :inbox_user, User, foreign_key: :inbox_project_id
    has_many :members, __MODULE__.Member
    has_many :tasks, Task
  end

  @behaviour Bodyguard.Schema

  def scope(query, %User{role: "admin"}, _), do: query

  def scope(query, %User{id: user_id}, _) do
    query
    |> join(:inner, [p], m in assoc(p, :members))
    |> where([p, m], m.user_id == ^user_id)
  end
end
