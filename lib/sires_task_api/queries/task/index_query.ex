defmodule SiresTaskApi.Task.IndexQuery do
  use SiresTaskApi.Query
  alias SiresTaskApi.{User, Task}

  @ts_vector "TO_TSVECTOR(? || ' ' || ?)"
  @ts_query "TO_TSQUERY(?)"
  @keyword_fragment "#{@ts_vector} @@ #{@ts_query}"
  @keyword_order_fragment "TS_RANK_CD(#{@ts_vector}, #{@ts_query})"

  @task_member_roles ~w(assignator responsible co-responsible observer)

  def build_query(%User{id: user_id} = user, dynamic, opts) do
    Task
    |> Bodyguard.scope(user)
    |> join(:left, [t], tm in Task.Member,
      on: tm.task_id == t.id and tm.user_id == ^user_id,
      as: :task_members
    )
    |> join(:left, [t], tg in assoc(t, :tags), as: :tags)
    |> join(:left, [t], p in assoc(t, :parent_tasks), as: :parents)
    |> where(^dynamic)
    |> add_order(opts[:params])
    |> distinct([t], t.id)
    |> preload([t], parent_references: :child_task, members: :user)
  end

  defp filter(dynamic, "search", value, _) do
    {:ok, dynamic([t], ^dynamic and fragment(@keyword_fragment, t.name, t.description, ^value))}
  end

  defp filter(dynamic, "project_id", project_id, _) do
    {:ok, dynamic([t], ^dynamic and t.project_id == ^project_id)}
  end

  defp filter(dynamic, "done", "true", _) do
    {:ok, dynamic([t], ^dynamic and t.done == true)}
  end

  defp filter(dynamic, "done", "false", _) do
    {:ok, dynamic([t], ^dynamic and t.done == false)}
  end

  defp filter(dynamic, "finish_date", finish_date, _) do
    with {:ok, _} <- Date.from_iso8601(finish_date) do
      from_dt = "#{finish_date}T00:00:00Z"
      to_dt = "#{finish_date}T23:59:59Z"
      {:ok, dynamic([t], ^dynamic and t.finish_time >= ^from_dt and t.finish_time <= ^to_dt)}
    end
  end

  defp filter(dynamic, "hot", _, _) do
    {:ok, dynamic([t], ^dynamic and fragment("? - NOW() < INTERVAL '7 days'", t.finish_time))}
  end

  defp filter(dynamic, "role", role, _) when role in @task_member_roles do
    {:ok, dynamic([task_members: tm], ^dynamic and tm.role == ^role)}
  end

  defp filter(dynamic, "tags", tags, _) when is_list(tags) do
    {:ok, dynamic([tags: tg], ^dynamic and tg.name in ^tags)}
  end

  defp filter(dynamic, "top_level", "true", _) do
    {:ok, dynamic([parents: p], ^dynamic and is_nil(p.id))}
  end

  defp filter(dynamic, "top_level", "false", _) do
    {:ok, dynamic([parents: p], ^dynamic and not is_nil(p.id))}
  end

  defp filter(dynamic, _, _, _) do
    {:ok, dynamic}
  end

  defp add_order(query, %{"search" => value}) do
    query |> order_by([t], desc: fragment(@keyword_order_fragment, t.name, t.description, ^value))
  end

  defp add_order(query, _) do
    query |> order_by(desc: :updated_at)
  end
end
