defmodule SiresTaskApi.Project.IndexQuery do
  use SiresTaskApi.Query

  def build_query(user, dynamic, _opts) do
    SiresTaskApi.Project
    |> Bodyguard.scope(user)
    |> where(^dynamic)
    |> order_by(desc: :updated_at)
  end

  defp filter(dynamic, "archived", "true", _) do
    {:ok, dynamic([p], ^dynamic and p.archived == true)}
  end

  defp filter(dynamic, "archived", "false", _) do
    {:ok, dynamic([p], ^dynamic and p.archived == false)}
  end

  defp filter(dynamic, _, _, _) do
    {:ok, dynamic}
  end
end
