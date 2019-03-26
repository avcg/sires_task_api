defmodule SiresTaskApi.Tag.IndexQuery do
  use SiresTaskApi.Query

  def build_query(_user, dynamic, _opts) do
    SiresTaskApi.Tag |> where(^dynamic) |> order_by(:name)
  end
end
