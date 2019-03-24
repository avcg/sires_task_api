defmodule SiresTaskApi.Project.IndexQuery do
  use SiresTaskApi.Query

  def build_query(user, dynamic, _opts) do
    SiresTaskApi.Project
    |> Bodyguard.scope(user)
    |> where(^dynamic)
    |> order_by(desc: :updated_at)
  end
end
