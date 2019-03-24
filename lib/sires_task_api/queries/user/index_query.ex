defmodule SiresTaskApi.User.IndexQuery do
  use SiresTaskApi.Query

  @ts_vector "TO_TSVECTOR(REGEXP_REPLACE(?, '[@\.\+_-]', ' ', 'g'))"
  @ts_query "TO_TSQUERY(REGEXP_REPLACE(?, '[@\.\+_-]', ' & ', 'g'))"
  @keyword_fragment "#{@ts_vector} @@ #{@ts_query}"
  @keyword_order_fragment "TS_RANK_CD(#{@ts_vector}, #{@ts_query})"

  def build_query(_user, dynamic, opts) do
    SiresTaskApi.User
    |> where(^dynamic)
    |> add_order(opts[:params])
  end

  defp filter(dynamic, "search", value, _) do
    {:ok, dynamic([u], ^dynamic and fragment(@keyword_fragment, u.email, ^value))}
  end

  defp filter(dynamic, _, _, _) do
    {:ok, dynamic}
  end

  defp add_order(query, %{"search" => value}) do
    query |> order_by([u], desc: fragment(@keyword_order_fragment, u.email, ^value))
  end

  defp add_order(query, _) do
    query |> order_by(desc: :inserted_at)
  end
end
