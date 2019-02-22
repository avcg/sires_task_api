defmodule SiresTaskApiWeb.Router do
  use SiresTaskApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public endpoints
  scope "/api/v1", SiresTaskApiWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create]
  end
end
