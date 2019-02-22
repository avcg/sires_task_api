defmodule SiresTaskApiWeb.Router do
  use SiresTaskApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SiresTaskApiWeb do
    pipe_through :api
  end
end
