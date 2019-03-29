# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sires_task_api,
  ecto_repos: [SiresTaskApi.Repo]

# Configures the endpoint
config :sires_task_api, SiresTaskApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XEmyzBRrylwDb3ldG3yvAIQ3LgA1y6Mjyopr+xCPRZ5/W2fthvGgq9UN0jeGAVJr",
  render_errors: [view: SiresTaskApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: SiresTaskApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_operation, repo: SiresTaskApi.Repo

config :sires_task_api, SiresTaskApiWeb.Guardian,
  issuer: "sires_task_api",
  secret_key: "lGJvqIfuWT8bLPU9PFJqzPXjkdoA4JJB+pT1YOmr7i+AH8YBWs5AduMuUfTv2pR2"

config :arc, storage: Arc.Storage.Local

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
