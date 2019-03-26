defmodule SiresTaskApi.Task.SharedHelpers do
  import Ecto.Changeset
  import Ecto.Query
  alias SiresTaskApi.{Repo, Tag, Task.Comment}

  def changeset(struct, attrs, tags) do
    struct
    |> cast(attrs, [:name, :description, :start_time, :finish_time])
    |> validate_length(:name, max: 255)
    |> validate_start_and_finish_times()
    |> put_tags(tags)
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

  defp put_tags(changeset, nil), do: changeset
  defp put_tags(changeset, tags), do: changeset |> put_assoc(:tags, tags)

  def find_tags(nil), do: nil
  def find_tags(ids), do: Tag |> where([t], t.id in ^ids) |> Repo.all()

  def comment_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end

  def ensure_task_id(%Comment{task_id: task_id}, task_id), do: {:ok, true}
  def ensure_task_id(_, _), do: {:error, :not_found}
end
