defmodule SiresTaskApi.Notifier.Policy.Project do
  use SiresTaskApi.Notifier.Policy

  def notify?("Create", user, %{create_project: project}), do: do_notify?(user, project)
  def notify?("Update", user, %{update_project: project}), do: do_notify?(user, project)
  def notify?(_operation, user, %{project: project}), do: do_notify?(user, project)
  def notify?(_operation, _user, _txn), do: false

  defp do_notify?(user, project) do
    Bodyguard.permit?(SiresTaskApi.ProjectPolicy, :show, user, project)
  end
end
