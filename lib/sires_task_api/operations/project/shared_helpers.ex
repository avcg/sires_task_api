defmodule SiresTaskApi.Project.SharedHelpers do
  import Ecto.Changeset
  alias SiresTaskApi.{Repo, Project}

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name, :archived])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
  end

  def find_member(project, user_id) do
    case Project.Member |> Repo.get_by(project_id: project.id, user_id: user_id) do
      %Project.Member{} = member -> {:ok, member}
      nil -> {:error, :not_found}
    end
  end
end
