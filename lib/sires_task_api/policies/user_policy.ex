defmodule SiresTaskApi.UserPolicy do
  @behaviour Bodyguard.Policy
  alias SiresTaskApi.User

  def authorize(:toggle_active, %User{role: "admin"}, _), do: true
  def authorize(_, _, _), do: false
end
