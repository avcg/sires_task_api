defmodule SiresTaskApi.Operation do
  import ExOperation.DSL

  defmacro __using__(opts) do
    quote do
      use ExOperation.Operation, unquote(opts)
      import SiresTaskApi.Operation
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
end
