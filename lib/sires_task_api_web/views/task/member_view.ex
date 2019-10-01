defmodule SiresTaskApiWeb.Task.MemberView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.UserView

  def render("index.json", %{members: members}) do
    %{members: members |> Enum.map(&member/1)}
  end

  def render("show.json", %{member: member}) do
    %{member: member(member)}
  end

  def member(member) do
    member
    |> Map.take([:role, :inserted_at])
    |> Map.put(:user, UserView.user(member.user))
  end
end
