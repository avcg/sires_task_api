defmodule SiresTaskApi.Tag.Update do
  use SiresTaskApi.Operation, params: %{id!: :integer, tag!: %{name!: :string}}
  alias SiresTaskApi.{Repo, Tag, TagPolicy}

  def build(op) do
    op
    |> find(:tag, schema: Tag)
    |> authorize(:tag, policy: TagPolicy, action: :update)
    |> step(:update_tag, &update_tag(&1.tag, op.params.tag, op.context.user))
  end

  defp update_tag(tag, params, editor) do
    tag
    |> Tag.SharedHelpers.changeset(params)
    |> Ecto.Changeset.put_change(:editor_id, editor.id)
    |> Repo.update()
  end
end
