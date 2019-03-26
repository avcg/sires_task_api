defmodule SiresTaskApiWeb.Task.CommentView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.UserView

  def render("show.json", %{comment: comment}) do
    %{comment: comment(comment)}
  end

  def comment(comment) do
    comment
    |> Map.take([:id, :text, :inserted_at, :updated_at])
    |> Map.put(:author, UserView.user(comment.author))
  end
end
