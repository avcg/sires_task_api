defmodule SiresTaskApi.Notifier.Policy.Task do
  use SiresTaskApi.Notifier.Policy

  def notify?("Create", user, %{create_task: task}), do: do_notify?(user, task)
  def notify?("Update", user, %{update_task: task}), do: do_notify?(user, task)
  def notify?(_operation, user, %{comment: comment}), do: do_notify?(user, comment.task)
  def notify?(_operation, user, %{parent_task: task}), do: do_notify?(user, task)
  def notify?(_operation, user, %{task: task}), do: do_notify?(user, task)
  def notify?(_operation, _user, _txn), do: false

  defp do_notify?(user, task) do
    Bodyguard.permit?(SiresTaskApi.TaskPolicy, :show, user, task)
  end
end
