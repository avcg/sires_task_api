defmodule SiresTaskApi.Notifier.Policy.User do
  use SiresTaskApi.Notifier.Policy

  def notify?("Create", %SiresTaskApi.User{role: "admin"}, _txn), do: true
  def notify?(_operation, _user, _txn), do: false
end
