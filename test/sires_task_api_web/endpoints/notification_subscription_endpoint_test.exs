defmodule SiresTaskApiWeb.NotificationSubscriptionEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  setup %{conn: conn} do
    user = insert!(:user)
    {:ok, conn: conn |> sign_as(user), user: user}
  end

  describe "GET /api/v1/notification_subscriptions" do
    test "list notification subscriptions", ctx do
      notification_subscription =
        insert!(
          :notification_subscription,
          user: ctx.user,
          media: "email",
          operation: "Task.Create"
        )

      response = ctx.conn |> get("/api/v1/notification_subscriptions?media=email") |> json_response(200)
      assert result = response["notification_subscriptions"] |> List.first()
      assert result["media"] == [notification_subscription.media]
      assert result["operation"] == notification_subscription.operation
    end
  end

  describe "POST /api/v1/notification_subscriptions" do
    test "create notification subscriptions", ctx do
      insert!(
        :notification_subscription,
        user: ctx.user,
        media: "email",
        operation: "Task.Create"
      )

      params = %{media: "email", operations: ~w(Task.Create Task.Update)}

      ctx.conn
      |> post("api/v1/notification_subscriptions", notification_subscriptions: params)
      |> json_response(201)

      response = ctx.conn |> get("/api/v1/notification_subscriptions") |> json_response(200)
      subs = response["notification_subscriptions"]

      for operation <- params.operations do
        assert sub = subs |> Enum.find(&(&1["operation"] == operation))
        assert sub["media"] == [params.media]
      end
    end
  end

  describe "DELETE /api/v1/notification_subscriptions" do
    test "list notification subscriptions", ctx do
      operations = ~w(Task.Create Task.Update)

      for op <- operations do
        insert!(:notification_subscription, user: ctx.user, media: "email", operation: op)
      end

      params = %{media: "email", operations: operations}

      ctx.conn
      |> delete("/api/v1/notification_subscriptions", notification_subscriptions: params)
      |> json_response(200)

      response = ctx.conn |> get("api/v1/notification_subscriptions") |> json_response(200)
      assert response["notification_subscriptions"] == []
    end
  end
end
