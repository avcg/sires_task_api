defmodule SiresTaskApi.Project.Member do
  use Ecto.Schema

  @primary_key false
  schema "project_members" do
    field :role, :string, default: "regular"
    timestamps(updated_at: false)

    belongs_to :project, SiresTaskApi.Project, primary_key: true
    belongs_to :user, SiresTaskApi.User, primary_key: true
  end
end
