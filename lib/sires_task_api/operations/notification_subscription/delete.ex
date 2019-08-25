defmodule SiresTaskApi.NotificationSubscription.Delete do
  use SiresTaskApi.Operation,
    params: %{
      notification_subscriptions!: %{
        media!: :string,
        operations!: [:string]
      }
    }

  alias SiresTaskApi.{Repo, NotificationSubscription}

  defdelegate validate_params(changeset), to: NotificationSubscription.SharedHelpers

  def build(op) do
    op
    |> step(:delete_notification_subscriptions, fn _ ->
      delete_notification_subscriptions(op.params.notification_subscriptions, op.context.user)
    end)
  end

  def delete_notification_subscriptions(params, user) do
    with {:ok, query} <- user |> NotificationSubscription.DeleteQuery.call(params: params) do
      Repo.delete_all(query)
      {:ok, nil}
    end
  end
end
