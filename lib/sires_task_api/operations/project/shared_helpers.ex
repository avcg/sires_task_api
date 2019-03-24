defmodule SiresTaskApi.Project.SharedHelpers do
  import Ecto.Changeset

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
  end
end
