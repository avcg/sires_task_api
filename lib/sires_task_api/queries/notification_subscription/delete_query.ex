defmodule SiresTaskApi.NotificationSubscription.DeleteQuery do
  use SiresTaskApi.Query

  def build_query(user, dynamic, _opts) do
    SiresTaskApi.NotificationSubscription
    |> Bodyguard.scope(user)
    |> where(^dynamic)
  end

  defp filter(dynamic, "media", value, _) do
    {:ok, dynamic([ns], ^dynamic and ns.media == ^value)}
  end

  defp filter(dynamic, "operations", values, _) do
    {:ok, dynamic([ns], ^dynamic and ns.operation in ^values)}
  end

  defp filter(dynamic, _, _, _) do
    {:ok, dynamic}
  end
end
