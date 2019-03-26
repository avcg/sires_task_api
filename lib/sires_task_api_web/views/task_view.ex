defmodule SiresTaskApiWeb.TaskView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.{ProjectView, UserView, AttachmentView, TagView}
  alias SiresTaskApiWeb.Task.{MemberView, ReferenceView, CommentView}

  @fields ~w(id name description start_time finish_time done inserted_at updated_at)a

  def render("show.json", %{task: task}) do
    %{task: task(task, :full)}
  end

  def task(task), do: task(task, :short)

  def task(task, :short) do
    task |> Map.take(@fields)
  end

  def task(task, :full) do
    task
    |> task(:short)
    |> Map.put(:project, ProjectView.project(task.project))
    |> Map.put(:creator, UserView.user(task.creator))
    |> Map.put(:editor, UserView.user(task.editor))
    |> Map.put(:members, Enum.map(task.members, &MemberView.member/1))
    |> Map.put(:attachments, Enum.map(task.attachments, &AttachmentView.attachment/1))
    |> Map.put(:tags, Enum.map(task.tags, &TagView.tag/1))
    |> Map.put(:child_references, Enum.map(task.child_references, &child_reference/1))
    |> Map.put(:parent_references, Enum.map(task.parent_references, &parent_reference/1))
    |> Map.put(:comments, Enum.map(task.comments, &CommentView.comment/1))
  end

  defp child_reference(reference), do: ReferenceView.reference(reference, :parent_task)
  defp parent_reference(reference), do: ReferenceView.reference(reference, :child_task)
end
