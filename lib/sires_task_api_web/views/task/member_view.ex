defmodule SiresTaskApiWeb.Task.MemberView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.UserView

  def render("show.json", %{member: member}) do
    %{member: member(member)}
  end

  def member(member) do
    member
    |> Map.take([:role, :inserted_at])
    |> Map.put(:user, UserView.user(member.user))
  end
end
