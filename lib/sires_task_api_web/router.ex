defmodule SiresTaskApiWeb.Router do
  use SiresTaskApiWeb, :router

  pipeline :api do
    plug CORSPlug, origin: "*"
    plug :accepts, ["json"]
    plug :put_resp_content_type, "application/json"
  end

  pipeline :protected do
    plug SiresTaskApiWeb.Guardian.AuthPipeline
    plug SiresTaskApiWeb.PutLocale
  end

  # Public endpoints
  scope "/api/v1", SiresTaskApiWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create]

    post "/sign_in", SignInController, :sign_in
    options "/sign_in", SignInController, :options
  end

  # Protected endpoints
  scope "/api/v1", SiresTaskApiWeb do
    pipe_through [:api, :protected]

    get "/current_user", CurrentUserController, :show
    options "/current_user", CurrentUserController, :options

    get "/tasks/calendar", TaskController, :calendar, as: :calendar
    options "/tasks/calendar", TaskController, :options

    resources "/users", UserController, only: [:index, :show, :update] do
      post "/deactivate", UserController, :deactivate, as: :deactivate
      options "/deactivate", UserController, :options

      post "/activate", UserController, :activate, as: :activate
      options "/activate", UserController, :options
    end

    options "/users", UserController, :options
    options "/users/:id", UserController, :options

    resources "/projects", ProjectController, only: [:index, :show, :create, :update, :delete] do
      resources "/members", Project.MemberController, only: [:create, :update, :delete]
      options "/members", Project.MemberController, :options
    end

    options "/projects", ProjectController, :options
    options "/projects/:id", ProjectController, :options

    resources "/tasks", TaskController, only: [:index, :show, :create, :update, :delete] do
      post "/mark_undone", TaskController, :mark_undone, as: :mark_undone
      options "/mark_undone", TaskController, :options

      post "/mark_done", TaskController, :mark_done, as: :mark_done
      options "/mark_done", TaskController, :options

      resources "/members", Task.MemberController, only: [:create, :delete]
      options "/members", Task.MemberController, :options

      resources "/references", Task.ReferenceController, only: [:create, :delete]
      options "/references", Task.ReferenceController, :options

      resources "/comments", Task.CommentController, only: [:create, :update, :delete]
      options "/comments", Task.CommentController, :options

      resources "/attachments", Task.AttachmentController, only: [] do
        resources "/versions", Task.Attachment.VersionController, only: [:index, :create]
        options "/versions", Task.Attachment.VersionController, :options
      end

      options "/attachments", Task.AttachmentController, :options
    end

    options "/tasks", TaskController, :options
    options "/tasks/:id", TaskController, :options

    resources "/tags", TagController, only: [:index, :create, :update, :delete]
    options "/tags", TagController, :options

    resources "/notification_subscriptions", NotificationSubscriptionController,
      only: [:index, :create]

    delete "/notification_subscriptions", NotificationSubscriptionController, :delete
    options "/notification_subscriptions", NotificationSubscriptionController, :options
  end

  # Swagger (API live documentation)
  scope "/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :sires_task_api,
      swagger_file: "swagger.json",
      disable_validator: true
  end
end
