defmodule SiresTaskApi.User do
  use Ecto.Schema
  use Arc.Ecto.Schema

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :active, :boolean, default: true
    field :role, :string, default: "regular"
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :position, :string
    field :avatar, __MODULE__.Avatar.Type
    field :locale, :string
    timestamps()

    belongs_to :inbox_project, SiresTaskApi.Project
  end

  def full_name(%__MODULE__{first_name: first, middle_name: middle, last_name: last}) do
    [first, middle, last] |> Enum.join(" ")
  end
end
