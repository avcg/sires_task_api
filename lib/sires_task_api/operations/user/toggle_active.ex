defmodule SiresTaskApi.User.ToggleActive do
  use SiresTaskApi.Operation, params: %{id!: :integer, active!: :boolean}
  alias SiresTaskApi.{Repo, User, UserPolicy}

  def call(op) do
    op
    |> find(:user, schema: User)
    |> authorize(:user, policy: UserPolicy, action: :toggle_active)
    |> step(:update_user, &toggle_active(&1.user, op.params.active))
  end

  defp toggle_active(user, active) do
    user |> Ecto.Changeset.change(%{active: active}) |> Repo.update()
  end
end
