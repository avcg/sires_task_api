defmodule SiresTaskApi.CommentPolicy do
  @behaviour Bodyguard.Policy

  alias SiresTaskApi.{User, ProjectPolicy}

  def authorize(_, %User{role: "admin"}, _), do: true

  def authorize(:create, user, task) do
    ProjectPolicy.member?(user, task.project, ~w(admin regular guest))
  end

  def authorize(action, user, comment) when action in [:update, :delete] do
    user.id == comment.author_id || ProjectPolicy.member?(user, comment.task.project, ~w(admin))
  end

  def authorize(_, _, _) do
    false
  end
end
