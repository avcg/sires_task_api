defmodule SiresTaskApi.UserPolicy do
  @behaviour Bodyguard.Policy
  alias SiresTaskApi.User

  def authorize(_, %User{role: "admin"}, _), do: true
  def authorize(:update, %User{id: id}, %User{id: id}), do: true
  def authorize(_, _, _), do: false
end
