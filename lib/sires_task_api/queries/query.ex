defmodule SiresTaskApi.Query do
  defmacro __using__(_) do
    quote do
      import Ecto.Query

      def call(user, opts \\ []) do
        with {:ok, prepared_params} <- user |> prepare_params(opts[:params]),
             {:ok, dynamic} <- prepared_params |> apply_filters() do
          {:ok, build_query(user, dynamic, opts)}
        end
      end

      def total_count_query(query) do
        sub = query |> exclude(:order_by) |> exclude(:preload)
        from(s in subquery(sub), select: count(s.id, :distinct))
      end

      defp apply_filters(params) do
        Enum.reduce_while(params, {:ok, true}, fn {filter, value}, {:ok, acc} ->
          case filter(acc, to_string(filter), value, params) do
            {:ok, dynamic} -> {:cont, {:ok, dynamic}}
            {:error, reason} -> {:halt, {:error, reason}}
          end
        end)
      end

      defp prepare_params(_user, nil), do: {:ok, %{}}
      defp prepare_params(_user, params), do: {:ok, params}
      defp filter(dynamic, _, _, _), do: {:ok, dynamic}

      defoverridable prepare_params: 2, filter: 4
    end
  end
end
