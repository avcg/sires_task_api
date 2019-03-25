defmodule SiresTaskApi.Task.SharedHelpers do
  import Ecto.Changeset

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name, :description, :start_time, :finish_time])
    |> validate_length(:name, max: 255)
    |> validate_start_and_finish_times()
  end

  defp validate_start_and_finish_times(changeset) do
    start = changeset |> get_field(:start_time)
    finish = changeset |> get_field(:finish_time)

    if start && finish && DateTime.compare(start, finish) == :gt do
      changeset |> add_error(:finish_time, "can't be earlier than start time")
    else
      changeset
    end
  end
end
