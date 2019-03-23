defmodule SiresTaskApi.User do
  use Ecto.Schema

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :active, :boolean, default: true
    field :role, :string, default: "regular"
    timestamps()
  end
end
