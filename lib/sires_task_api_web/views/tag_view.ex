defmodule SiresTaskApiWeb.TagView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.UserView

  def render("index.json", %{tags: tags, pagination: pagination}) do
    %{tags: Enum.map(tags, &tag(&1, :full)), total_count: pagination.total_count}
  end

  def render("show.json", %{tag: tag}) do
    %{tag: tag(tag, :full)}
  end

  def tag(tag), do: tag(tag, :short)

  def tag(tag, :short) do
    tag
    |> Map.take([:id, :name])
  end

  def tag(tag, :full) do
    tag
    |> Map.take([:id, :name, :inserted_at, :updated_at])
    |> Map.put(:creator, UserView.user(tag.creator))
    |> Map.put(:editor, UserView.user(tag.editor))
  end
end
