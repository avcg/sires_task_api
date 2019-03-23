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
  end
end
