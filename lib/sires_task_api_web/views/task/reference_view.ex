defmodule SiresTaskApiWeb.Task.ReferenceView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.TaskView

  def render("show.json", %{reference: reference}) do
    %{reference: reference(reference, :child_task)}
  end

  def reference(reference, key) do
    reference
    |> Map.take([:reference_type, :inserted_at])
    |> Map.put(:task, reference |> Map.fetch!(key) |> TaskView.task())
  end
end
