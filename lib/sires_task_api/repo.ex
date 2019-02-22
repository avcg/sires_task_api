defmodule SiresTaskApi.Repo do
  use Ecto.Repo,
    otp_app: :sires_task_api,
    adapter: Ecto.Adapters.Postgres
end
