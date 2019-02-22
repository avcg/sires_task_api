defmodule SiresTaskApi.Tag do
  use Ecto.Schema

  schema "tags" do
    field :name, :string
    timestamps()

    belongs_to :creator, SiresTaskApi.User
    belongs_to :editor, SiresTaskApi.User
  end
end
