defmodule SiresTaskApiWeb.Controller.Helpers.Pagination do
  defstruct offset: nil, limit: nil, total_count: nil

  @default_limit 20
  @max_limit 500

  import Ecto.Query
  alias SiresTaskApi.Repo

  def paginate(query, params) do
    pagination = %__MODULE__{
      offset: params["offset"] |> cast_offset(),
      limit: params["limit"] |> cast_limit(),
      total_count: total_count(query)
    }

    {page(query, pagination), pagination}
  end

  def paginate_or_all(query, params) do
    case params do
      %{"limit" => _, "offset" => _} ->
        paginate(query, params)

      _ ->
        {Repo.all(query), %{total_count: total_count(query)}}
    end
  end

  defp cast_offset(value) do
    case value |> to_string() |> Integer.parse() do
      {offset, ""} when offset >= 0 -> offset
      _ -> 0
    end
  end

  defp cast_limit(value) do
    case value |> to_string() |> Integer.parse() do
      {limit, ""} when limit >= 0 and limit < @max_limit -> limit
      _ -> @default_limit
    end
  end

  defp total_count(list) when is_list(list), do: list |> Enum.count()
  defp total_count(query), do: query |> Repo.aggregate(:count, :id)

  defp page(list, %{offset: offset, limit: limit}) when is_list(list),
    do: list |> Enum.slice(offset, limit)

  defp page(query, %{offset: offset, limit: limit}),
    do: query |> offset(^offset) |> limit(^limit) |> Repo.all()
end
