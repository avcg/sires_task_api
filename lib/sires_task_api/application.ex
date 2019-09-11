defmodule SiresTaskApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      SiresTaskApi.Repo,
      # Start the endpoint when the application starts
      SiresTaskApiWeb.Endpoint,
      # Starts a worker by calling: SiresTaskApi.Worker.start_link(arg)
      # {SiresTaskApi.Worker, arg},
      {Phoenix.PubSub.PG2, name: SiresTaskApi.DomainPubSub}
    ]

    children =
      if Mix.env() == :test do
        children
      else
        children ++ [SiresTaskApi.Notifier]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SiresTaskApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SiresTaskApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
