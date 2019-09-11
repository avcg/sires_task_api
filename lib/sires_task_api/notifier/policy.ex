defmodule SiresTaskApi.Notifier.Policy do
  @callback notify?(operation :: String.t(), user :: SiresTaskApi.User.t(), txn :: map()) :: bool

  defmacro __using__(_opts) do
    quote do
      @behaviour SiresTaskApi.Notifier.Policy
      import SiresTaskApi.Notifier.Policy
    end
  end

  defmacro delegate(scope, policy) do
    quote bind_quoted: [scope: scope, policy: policy] do
      split_scope = [scope] |> Module.concat() |> Module.split()
      split_scope_len = Enum.count(split_scope)

      for operation <- SiresTaskApi.Notifier.available_operations() do
        split_operation = [operation] |> Module.concat() |> Module.split()

        if Enum.slice(split_operation, 0..(split_scope_len - 1)) == split_scope do
          tail_operation =
            split_operation
            |> Enum.slice(split_scope_len..-1)
            |> Module.concat()
            |> to_string()
            |> String.replace("Elixir.", "", global: false)

          def notify?(unquote(operation), user, txn) do
            unquote(policy).notify?(unquote(tail_operation), user, txn)
          end
        end
      end
    end
  end
end
