defmodule SiresTaskApi.Task.CalendarQuery do
  use SiresTaskApi.Query
  alias SiresTaskApi.Task

  @month_fragment "EXTRACT(YEAR FROM ?) = ? AND EXTRACT(MONTH FROM ?) = ?"
  @task_member_roles ~w(assignator responsible co-responsible observer)

  defp prepare_params(_user, %{"year" => year, "month" => month} = params) do
    with {:ok, {year, month}} <- parse_month(year, month) do
      {:ok, Map.merge(params, %{"year" => year, "month" => month})}
    end
  end

  defp prepare_params(_user, _params) do
    {:error, :missing_year_or_month}
  end

  defp parse_month(year, month) do
    case [year, month] |> Enum.map(&(&1 |> to_string() |> Integer.parse())) do
      [{year, ""}, {month, ""}] when year in 2000..9999 and month in 1..12 -> {:ok, {year, month}}
      _ -> {:error, :bad_year_or_month}
    end
  end

  def build_query(user, dynamic, params: %{"year" => year, "month" => month}) do
    Task
    |> Bodyguard.scope(user)
    |> join(:left, [t], tm in Task.Member, on: tm.task_id == t.id, as: :task_members)
    |> where(^dynamic)
    |> where([t], fragment(@month_fragment, t.finish_time, ^year, t.finish_time, ^month))
    |> order_by([t], t.finish_time)
    |> distinct([t], t.id)
    |> preload([t], parent_references: :child_task, members: :user)
  end

  defp filter(dynamic, "user_id", user_id, _) do
    {:ok, dynamic([task_members: tm], ^dynamic and tm.user_id == ^user_id)}
  end

  defp filter(dynamic, "role", role, _) when role in @task_member_roles do
    {:ok, dynamic([task_members: tm], ^dynamic and tm.role == ^role)}
  end

  defp filter(dynamic, _, _, _) do
    {:ok, dynamic}
  end
end
