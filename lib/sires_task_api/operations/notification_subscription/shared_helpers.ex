defmodule SiresTaskApi.NotificationSubscription.SharedHelpers do
  alias SiresTaskApi.Notifier

  def validate_params(changeset) do
    Ecto.Changeset.validate_change(
      changeset,
      :notification_subscriptions,
      fn :notification_subscriptions, changeset  ->
        changeset
        |> Ecto.Changeset.validate_inclusion(:media, Notifier.available_media())
        |> Ecto.Changeset.validate_subset(:operations, Notifier.available_operations())
        |> Map.fetch!(:errors)
      end
    )
  end
end
