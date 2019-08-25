defmodule SiresTaskApiWeb.NotificationSubscriptionController do
  use SiresTaskApiWeb, :controller

  alias SiresTaskApi.{Repo, NotificationSubscription}

  def index(conn, params) do
    user = conn.assigns.current_user

    with {:ok, query} <- NotificationSubscription.IndexQuery.call(user, params) do
      conn |> render(notification_subscriptions: Repo.all(query))
    end
  end

  def create(conn, params) do
    with {:ok, _} <- NotificationSubscription.Create |> run(conn, params) do
      conn |> put_status(:created) |> json(%{result: "ok"})
    end
  end

  def delete(conn, params) do
    with {:ok, _} <- NotificationSubscription.Delete |> run(conn, params) do
      conn |> json(%{result: "ok"})
    end
  end
end
