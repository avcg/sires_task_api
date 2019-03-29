defmodule SiresTaskApiWeb.Task.CommentView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApi.Task.Comment.Attachment.Definition
  alias SiresTaskApiWeb.UserView

  def render("show.json", %{comment: comment}) do
    %{comment: comment(comment)}
  end

  def comment(comment) do
    comment
    |> Map.take([:id, :text, :inserted_at, :updated_at])
    |> Map.put(:author, UserView.user(comment.author))
    |> Map.put(:attachments, Enum.map(comment.attachments, &attachment/1))
  end

  defp attachment(attachment) do
    %{
      id: attachment.id,
      url: Definition.url({attachment.file, attachment}, :original, signed: true)
    }
  end
end
