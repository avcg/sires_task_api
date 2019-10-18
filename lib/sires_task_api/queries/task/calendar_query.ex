defmodule SiresTaskApi.Task.CalendarQuery do
  use SiresTaskApi.Query

  @month_fragment "EXTRACT(YEAR FROM ?) = ? AND EXTRACT(MONTH FROM ?) = ?"

  def build_query(user, dynamic, year: year, month: month) do
    SiresTaskApi.Task
    |> Bodyguard.scope(user)
    |> where(^dynamic)
    |> where([t], fragment(@month_fragment, t.finish_time, ^year, t.finish_time, ^month))
    |> order_by([t], t.finish_time)
    |> preload([t], parent_references: :child_task, members: :user)
  end
end
