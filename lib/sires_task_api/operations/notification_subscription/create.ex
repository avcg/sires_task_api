defmodule SiresTaskApi.NotificationSubscription.Create do
  use SiresTaskApi.Operation,
    params: %{
      notification_subscriptions!: %{
        media!: :string,
        operations!: [:string]
      }
    }

  alias SiresTaskApi.{Repo, NotificationSubscription, NotificationSubscriptionPolicy}

  defdelegate validate_params(changeset), to: NotificationSubscription.SharedHelpers

  def build(op) do
    op
    |> step(:authorize, fn _ ->
      authorize(op.context.user, op.params.notification_subscriptions.operations)
    end)
    |> step(:create_notification_subscriptions, fn _ ->
      create_notification_subscriptions(op.params.notification_subscriptions, op.context.user)
    end)
  end

  defp authorize(user, operations) do
    Enum.reduce_while(operations, {:ok, :authorized}, fn operation, _ ->
      case Bodyguard.permit(NotificationSubscriptionPolicy, :create, user, operation) do
        :ok -> {:cont, {:ok, :authorized}}
        error -> {:halt, error}
      end
    end)
  end

  defp create_notification_subscriptions(params, user) do
    rows = params.operations |> Enum.map(&%{media: params.media, operation: &1, user_id: user.id})
    NotificationSubscription |> Repo.insert_all(rows, on_conflict: :nothing)
    {:ok, nil}
  end
end
