defmodule SiresTaskApi.Tag.Create do
  use SiresTaskApi.Operation, params: %{tag!: %{name!: :string}}
  alias SiresTaskApi.{Repo, Tag, TagPolicy}

  def call(op) do
    op
    |> step(:authorize, fn _ -> authorize(op.context.user) end)
    |> step(:create_tag, fn _ -> create_tag(op.params.tag, op.context.user) end)
  end

  defp authorize(user) do
    case Bodyguard.permit(TagPolicy, :create, user) do
      :ok -> {:ok, :authorized}
      error -> error
    end
  end

  defp create_tag(params, creator) do
    %Tag{creator: creator, editor: creator}
    |> Tag.SharedHelpers.changeset(params)
    |> Repo.insert()
  end
end
