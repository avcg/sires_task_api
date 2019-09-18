defmodule SiresTaskApi.User.NotifierQuery do
  import Ecto.Query

  def call(%{media: media, operation: operation}) do
    SiresTaskApi.User
    |> join(:inner, [u], ns in assoc(u, :notification_subscriptions), as: :subscriptions)
    |> where([u, subscriptions: ns], ns.media == ^media and ns.operation == ^operation)
  end
end
