# SiresTaskApi [![Build Status](https://travis-ci.com/avcg/sires_task_api.svg?branch=master)](https://travis-ci.com/avcg/sires_task_api) [![Coverage Status](https://coveralls.io/repos/github/avcg/sires_task_api/badge.svg?branch=master)](https://coveralls.io/github/avcg/sires_task_api?branch=master)

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`
  * To create swagger.json `mix swagger`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## API

  * Swagger API spec: https://app.swaggerhub.com/apis/iMalut/sires-task_api/1.0

## Deps

  defp deps do
    [
      {:phoenix, "~> 1.4.1"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:guardian, "~> 1.0"},
      {:ex_operation, "~> 0.5"},
      {:bodyguard, "~> 2.2"},
      {:phoenix_swagger, "~> 0.8"},
      {:arc_ecto, "~> 0.11.0"},
      {:excoveralls, "~> 0.10", only: :test},
      {:edeliver, ">= 1.6.0"},
      {:distillery, "~> 2.0", warn_missing: false}
    ]
  end
