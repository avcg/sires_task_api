defmodule SiresTaskApi.NotificationSubscription do
  use Ecto.Schema

  import Ecto.Query

  alias SiresTaskApi.User

  @primary_key false
  schema "notification_subscriptions" do
    field :media, :string, primary_key: true
    field :operation, :string, primary_key: true
    belongs_to :user, SiresTaskApi.User, primary_key: true
  end

  @behaviour Bodyguard.Schema

  def scope(query, %User{id: user_id}, _) do
    query
    |> where([ns], ns.user_id == ^user_id)
  end
end
