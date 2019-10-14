defmodule SiresTaskApiWeb.TaskChannel do
  use SiresTaskApiWeb, :channel

  alias SiresTaskApi.{Task, TaskPolicy}
  alias SiresTaskApiWeb.TaskView
  alias SiresTaskApiWeb.Task.{Attachment, AttachmentView, CommentView, MemberView, ReferenceView}

  @operations %{
    Task.Create => "create",
    Task.Update => "update",
    Task.Delete => "delete",
    Task.ToggleDone => "toggle_done",
    Task.AddMember => "add_member",
    Task.RemoveMember => "remove_member",
    Task.AddAttachment => "add_attachment",
    Task.AddAttachmentVersion => "add_attachment_version",
    Task.DeleteAttachmentVersion => "delete_attachment_version",
    Task.AddComment => "add_comment",
    Task.ChangeComment => "change_comment",
    Task.RemoveComment => "remove_comment",
    Task.AddReference => "add_reference",
    Task.RemoveReference => "remove_reference"
  }

  @operation_modules Map.keys(@operations)

  def join("tasks", _, socket) do
    self() |> send(:after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    for mod <- @operation_modules, do: subscribe_to_operation(mod)
    {:noreply, socket}
  end

  def handle_info({:operation, op, txn}, socket) do
    if Bodyguard.permit?(TaskPolicy, :show, socket.assigns.current_user, fetch_task(op, txn)) do
      socket |> push(@operations[op], payload(op, txn))
    end

    {:noreply, socket}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  #############################################################################

  defp fetch_task(Task.Create, %{create_task: task}), do: task
  defp fetch_task(Task.Update, %{update_task: task}), do: task
  defp fetch_task(Task.ToggleDone, %{update_task: task}), do: task
  defp fetch_task(_, %{task: task}), do: task

  defp payload(Task.Create, txn), do: %{task: TaskView.task(txn.create_task)}
  defp payload(Task.Update, txn), do: %{task: TaskView.task(txn.update_task)}
  defp payload(Task.Delete, txn), do: %{task: TaskView.task(txn.task)}
  defp payload(Task.ToggleDone, txn), do: %{task: TaskView.task(txn.update_task)}

  defp payload(Task.AddMember, txn) do
    %{task_id: txn.task.id, member: MemberView.member(txn.add_member)}
  end

  defp payload(Task.RemoveMember, txn) do
    %{task_id: txn.task.id, member: MemberView.member(txn.member)}
  end

  defp payload(Task.AddAttachment, txn) do
    %{task_id: txn.task.id, attachment: AttachmentView.attachment(txn.attachment)}
  end

  defp payload(Task.AddAttachmentVersion, txn) do
    version = Attachment.VersionView.version(txn.upload_file)
    %{task_id: txn.task.id, attachment_id: txn.attachment.id, version: version}
  end

  defp payload(Task.DeleteAttachmentVersion, txn) do
    version = Attachment.VersionView.version(txn.version)
    %{task_id: txn.task.id, attachment_id: txn.attachment.id, version: version}
  end

  defp payload(Task.AddComment, txn) do
    %{task_id: txn.task.id, comment: CommentView.comment(txn.add_comment)}
  end

  defp payload(Task.ChangeComment, txn) do
    %{task_id: txn.task.id, comment: CommentView.comment(txn.upload_files)}
  end

  defp payload(Task.RemoveComment, txn) do
    %{task_id: txn.task.id, comment: CommentView.comment(txn.comment)}
  end

  defp payload(Task.AddReference, txn) do
    %{task_id: txn.task.id, reference: ReferenceView.reference(txn.add_reference)}
  end

  defp payload(Task.RemoveReference, txn) do
    %{task_id: txn.task.id, reference: ReferenceView.reference(txn.reference)}
  end
end
