defmodule SiresTaskApiWeb.NotificationSubscriptionView do
  use SiresTaskApiWeb, :view

  def render("index.json", %{notification_subscriptions: notification_subscriptions}) do
    notification_subscriptions_view =
      notification_subscriptions
      |> Enum.group_by(& &1.operation)
      |> Enum.map(fn {op, subs} -> %{operation: op, media: Enum.map(subs, & &1.media)} end)

    %{notification_subscriptions: notification_subscriptions_view}
  end

  def notification_subscription(notification_subscription) do
    notification_subscription
    |> Map.take(~w(media operation)a)
  end
end
