defmodule SiresTaskApiWeb.Swagger.NotificationSubscriptions do
  use PhoenixSwagger

  alias SiresTaskApi.Notifier

  def swagger_definitions do
    %{
      NotificationSubscription:
        swagger_schema do
          title("Notification subscription")

          properties do
            media(:string, "Media", required: true, enum: Notifier.available_media())

            operations(
              :array,
              "Operation",
              items: :string,
              required: true,
              enum: Notifier.available_operations()
            )
          end
        end
    }
  end

  swagger_path :index do
    get("/notification_subscriptions")
    tag("Notification subscriptions")
    summary("List notification subscriptions")

    parameters do
      media(:query, :string, "Filter by media", enum: Notifier.available_media())
    end

    response(200, "OK")
  end

  swagger_path :create do
    post("/notification_subscriptions")
    tag("Notification subscriptions")
    summary("Create notification subscriptions")

    parameters do
      body(
        :body,
        Schema.new do
          properties do
            notification_subscription(
              Schema.ref(:NotificationSubscription),
              "Notification subscription properties",
              required: true
            )
          end
        end,
        "Body",
        required: true
      )
    end

    response(201, "Created")
    response(400, "Bad Request")
    response(401, "Unauthorized")
    response(422, "Unprocessable Entity")
  end

  swagger_path :delete do
    delete("/notification_subscriptions")
    tag("Notification subscriptions")
    summary("Delete notification subscriptions")

    parameters do
      body(
        :body,
        Schema.new do
          properties do
            notification_subscription(
              Schema.ref(:NotificationSubscription),
              "Notification subscription properties",
              required: true
            )
          end
        end,
        "Body",
        required: true
      )
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end
end
