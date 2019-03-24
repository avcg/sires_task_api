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

    resources "/users", UserController, only: [:update] do
      post "/deactivate", UserController, :deactivate, as: :deactivate
      post "/activate", UserController, :activate, as: :activate
    end

    resources "/projects", ProjectController, only: [:create, :update]

    get "/current_user", CurrentUserController, :show
  end

  # Swagger (API live documentation)
  scope "/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :sires_task_api,
      swagger_file: "swagger.json",
      disable_validator: true
  end
end
