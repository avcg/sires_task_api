defmodule SiresTaskApiWeb.Router do
  use SiresTaskApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :put_resp_content_type, "application/json"
  end

  pipeline :protected do
    plug SiresTaskApiWeb.Guardian.AuthPipeline
  end

  # Public endpoints
  scope "/api/v1", SiresTaskApiWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create]

    post "/sign_in", SignInController, :sign_in
  end

  # Protected endpoints
  scope "/api/v1", SiresTaskApiWeb do
    pipe_through [:api, :protected]

    get "/current_user", CurrentUserController, :show

    resources "/users", UserController, only: [:index, :show, :update] do
      post "/deactivate", UserController, :deactivate, as: :deactivate
      post "/activate", UserController, :activate, as: :activate
    end

    resources "/projects", ProjectController, only: [:index, :show, :create, :update, :delete] do
      resources "/members", Project.MemberController, only: [:create, :update, :delete]
    end

    resources "/tasks", TaskController, only: [:show, :create, :update, :delete] do
      post "/mark_undone", TaskController, :mark_undone, as: :mark_undone
      post "/mark_done", TaskController, :mark_done, as: :mark_done

      resources "/members", Task.MemberController, only: [:create, :delete]
      resources "/references", Task.ReferenceController, only: [:create, :delete]
      resources "/comments", Task.CommentController, only: [:create, :update, :delete]
    end

    resources "/tags", TagController, only: [:index, :create, :update, :delete]
  end

  # Swagger (API live documentation)
  scope "/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :sires_task_api,
      swagger_file: "swagger.json",
      disable_validator: true
  end
end
