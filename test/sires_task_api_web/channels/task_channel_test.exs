defmodule SiresTaskApiWeb.TaskChannelTest do
  use SiresTaskApiWeb.ChannelCase

  alias SiresTaskApi.{Repo, Task}
  alias SiresTaskApiWeb.{UserSocket, TaskChannel}

  setup do
    user = insert!(:user)
    task = insert!(:task)
    member = insert!(:project_member, project: task.project, user: user, role: "regular")

    socket = UserSocket |> socket("tasks", %{current_user: user})
    {:ok, _, _} = socket |> subscribe_and_join(TaskChannel, "tasks", %{})

    {:ok, socket: socket, user: user, member: member, task: task}
  end

  test "create task", ctx do
    Task.Create |> dispatch(%{create_task: ctx.task})

    assert_push "create", %{task: msg_task}
    assert msg_task.id == ctx.task.id
  end

  test "update task", ctx do
    Task.Update |> dispatch(%{update_task: ctx.task})

    assert_push "update", %{task: msg_task}
    assert msg_task.id == ctx.task.id
  end

  test "delete task", ctx do
    Task.Delete |> dispatch(%{task: ctx.task})

    assert_push "delete", %{task: msg_task}
    assert msg_task.id == ctx.task.id
  end

  test "toggle done", ctx do
    Task.ToggleDone |> dispatch(%{update_task: ctx.task})

    assert_push "toggle_done", %{task: msg_task}
    assert msg_task.id == ctx.task.id
  end

  test "add member", ctx do
    member = insert!(:task_member, task: ctx.task, user: ctx.user, role: "responsible")
    Task.AddMember |> dispatch(%{task: ctx.task, add_member: member})

    assert_push "add_member", %{task: msg_task, member: msg_member}
    assert msg_task.id == ctx.task.id
    assert msg_member.user.id == ctx.user.id
    assert msg_member.role == "responsible"
  end

  test "remove member", ctx do
    member = insert!(:task_member, task: ctx.task, user: ctx.user, role: "responsible")
    Task.RemoveMember |> dispatch(%{task: ctx.task, member: member})

    assert_push "remove_member", %{task: msg_task, member: msg_member}
    assert msg_task.id == ctx.task.id
    assert msg_member.user.id == ctx.user.id
    assert msg_member.role == "responsible"
  end

  test "add attachment", ctx do
    attachment = insert!(:task_attachment, task: ctx.task)
    version = attachment.versions |> List.first() |> Repo.preload(:attachment)
    attachment = %{attachment | versions: [version]}
    Task.AddAttachment |> dispatch(%{task: ctx.task, attachment: attachment})

    assert_push "add_attachment", %{task: msg_task, attachment: msg_attachment}
    assert msg_task.id == ctx.task.id
    assert msg_attachment.last_version.id == version.id
  end

  test "add attachment version", ctx do
    attachment = insert!(:task_attachment, task: ctx.task)
    version = insert!(:task_attachment_version, attachment: attachment)
    attachment = attachment |> Repo.preload([versions: :attachment], force: true)

    Task.AddAttachmentVersion
    |> dispatch(%{task: ctx.task, new_attachment: attachment, version: version})

    assert_push(
      "add_attachment_version",
      %{task: msg_task, attachment: msg_attachment, version: msg_version}
    )

    assert msg_task.id == ctx.task.id
    assert msg_attachment.id == attachment.id
    assert msg_version.id == version.id
  end

  test "delete attachment version", ctx do
    attachment = insert!(:task_attachment, task: ctx.task)
    version = insert!(:task_attachment_version, attachment: attachment)
    attachment = attachment |> Repo.preload([versions: :attachment], force: true)

    Task.DeleteAttachmentVersion
    |> dispatch(%{task: ctx.task, new_attachment: attachment, version: version})

    assert_push(
      "delete_attachment_version",
      %{task: msg_task, attachment: msg_attachment, version: msg_version}
    )

    assert msg_task.id == ctx.task.id
    assert msg_attachment.id == attachment.id
    assert msg_version.id == version.id
  end

  test "add comment", ctx do
    comment = insert!(:task_comment, task: ctx.task) |> Repo.preload(:attachments)
    Task.AddComment |> dispatch(%{task: ctx.task, upload_files: comment})

    assert_push "add_comment", %{task: msg_task, comment: msg_comment}
    assert msg_task.id == ctx.task.id
    assert msg_comment.id == comment.id
  end

  test "change comment", ctx do
    comment = insert!(:task_comment, task: ctx.task) |> Repo.preload(:attachments)
    Task.ChangeComment |> dispatch(%{task: ctx.task, upload_files: comment})

    assert_push "change_comment", %{task: msg_task, comment: msg_comment}
    assert msg_task.id == ctx.task.id
    assert msg_comment.id == comment.id
  end

  test "remove comment", ctx do
    comment = insert!(:task_comment, task: ctx.task) |> Repo.preload(:attachments)
    Task.RemoveComment |> dispatch(%{task: ctx.task, comment: comment})

    assert_push "remove_comment", %{task: msg_task, comment: msg_comment}
    assert msg_task.id == ctx.task.id
    assert msg_comment.id == comment.id
  end

  test "add reference", ctx do
    subtask = insert!(:task, project: ctx.task.project)
    reference = insert!(:task_reference, parent_task: ctx.task, child_task: subtask)
    Task.AddReference |> dispatch(%{task: ctx.task, add_reference: reference})

    assert_push "add_reference", %{task: msg_task, reference: msg_reference}
    assert msg_task.id == ctx.task.id
    assert msg_reference.reference_type == reference.reference_type
    assert msg_reference.task.id == subtask.id
  end

  test "remove reference", ctx do
    subtask = insert!(:task, project: ctx.task.project)
    reference = insert!(:task_reference, parent_task: ctx.task, child_task: subtask)
    Task.RemoveReference |> dispatch(%{task: ctx.task, reference: reference})

    assert_push "remove_reference", %{task: msg_task, reference: msg_reference}
    assert msg_task.id == ctx.task.id
    assert msg_reference.reference_type == reference.reference_type
    assert msg_reference.task.id == subtask.id
  end

  test "no message when not authorized", ctx do
    ctx.member |> Repo.delete()
    Task.Create |> dispatch(%{create_task: ctx.task})

    refute_push "create", _
  end
end
