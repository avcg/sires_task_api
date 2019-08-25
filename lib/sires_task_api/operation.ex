defmodule SiresTaskApi.Operation do
  import ExOperation.DSL

  @callback build(op :: ExOperation.Operation.t()) :: ExOperation.Operation.t()

  defmacro __using__(opts) do
    quote do
      use ExOperation.Operation, unquote(opts)
      import SiresTaskApi.Operation

      @behaviour SiresTaskApi.Operation

      def call(op) do
        op
        |> build()
        |> after_commit(&publish(&1))
      end

      @pubsub_topic "operation:#{SiresTaskApi.Operation.dump(__MODULE__)}"

      def publish(txn) do
        SiresTaskApi.DomainPubSub
        |> Phoenix.PubSub.broadcast(@pubsub_topic, {:operation, __MODULE__, txn})
        |> case do
          :ok -> {:ok, txn}
          {:error, reason} -> {:error, reason}
        end
      end
    end
  end

  def authorize(op, step_name, policy: policy, action: action) do
    step(op, {:authorize, step_name}, fn txn ->
      case txn[step_name] do
        nil -> {:ok, :noop}
        entity -> do_authorize(policy, action, op.context.user, entity)
      end
    end)
  end

  defp do_authorize(policy, action, user, entity) do
    case Bodyguard.permit(policy, action, user, entity) do
      :ok -> {:ok, :ok}
      {:error, reason} -> {:error, reason}
    end
  end

  # Elixir.SiresTaskApi.Foo.Bar.Create => "Foo.Bar.Create"
  def dump(mod) do
    mod |> to_string() |> String.replace("Elixir.SiresTaskApi.", "", global: false)
  end
end
