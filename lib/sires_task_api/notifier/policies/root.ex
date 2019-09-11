defmodule SiresTaskApi.Notifier.Policy.Root do
  use SiresTaskApi.Notifier.Policy

  alias SiresTaskApi.Notifier.Policy

  delegate("User", Policy.User)
  delegate("Project", Policy.Project)
  delegate("Task", Policy.Task)

  def notify?(_operation, _user, _txn), do: false
end
