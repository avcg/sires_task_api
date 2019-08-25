defmodule SiresTaskApi.Tag.Delete do
  use SiresTaskApi.Operation, params: %{id!: :integer}
  alias SiresTaskApi.{Repo, Tag, TagPolicy}

  def build(op) do
    op
    |> find(:tag, schema: Tag)
    |> authorize(:tag, policy: TagPolicy, action: :delete)
    |> step(:delete_tag, &Repo.delete(&1.tag))
  end
end
