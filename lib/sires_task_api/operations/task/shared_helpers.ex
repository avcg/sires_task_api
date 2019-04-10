defmodule SiresTaskApi.Task.SharedHelpers do
  import Ecto.Changeset
  import Ecto.Query
  import Arc.Ecto.Schema
  alias SiresTaskApi.{Repo, Task, Tag}

  def changeset(%Task{} = struct, attrs, tags) do
    struct
    |> cast(attrs, [:name, :description, :start_time, :finish_time, :project_id])
    |> cast_assoc(:attachments,
      with: fn struct, attrs ->
        # Save attachment version with empty `file` field so far. See explanation below.
        struct
        |> cast(Map.put(attrs, :versions, [%{}]), [])
        |> cast_assoc(:versions, with: &cast(&1, &2, []))
      end
    )
    |> validate_length(:name, max: 255)
    |> validate_start_and_finish_times()
    |> put_tags(tags)
  end

  # We have to insert all the records (task, attachment & version) at first to get their ids.
  # Only then we can use these ids to store the file into the proper directory.
  # The we update the version record's `file` field with the storage path.
  def upload_attachments(_task, nil), do: {:ok, :noop}
  def upload_attachments(_task, []), do: {:ok, :noop}

  def upload_attachments(%Task{} = task, attachments) do
    length = attachments |> Enum.count()
    query = Task.Attachment |> order_by(desc: :id) |> limit(^length)
    task = task |> Repo.preload(attachments: {query, [versions: :attachment]})

    task.attachments
    |> Enum.zip(attachments)
    |> Enum.reduce_while({:ok, []}, fn {%{versions: [version]}, attrs}, {:ok, acc} ->
      case version |> attachment_changeset(attrs) |> Repo.update() do
        {:ok, version} -> {:cont, {:ok, [version | acc]}}
        other -> {:halt, other}
      end
    end)
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

  def comment_changeset(%Task.Comment{} = struct, attrs) do
    struct
    |> cast(attrs, [:text])
    |> cast_assoc(:attachments, with: &cast(&1, &2, []))
    |> validate_required([:text])
  end

  # The same thing with comment attachments as with task attachments. See above.
  def upload_comment_attachments(_comment, nil), do: {:ok, :noop}
  def upload_comment_attachments(_comment, []), do: {:ok, :noop}

  def upload_comment_attachments(%Task.Comment{} = comment, attachments) do
    length = attachments |> Enum.count()
    query = Task.Comment.Attachment |> order_by(desc: :id) |> limit(^length)
    comment = comment |> Repo.preload(attachments: {query, [:comment]})

    comment.attachments
    |> Enum.zip(attachments)
    |> Enum.reduce_while({:ok, []}, fn {attachment, attrs}, {:ok, acc} ->
      case attachment |> attachment_changeset(attrs) |> Repo.update() do
        {:ok, version} -> {:cont, {:ok, [version | acc]}}
        other -> {:halt, other}
      end
    end)
  end

  def ensure_task_id(%{task_id: task_id}, task_id), do: {:ok, true}
  def ensure_task_id(_, _), do: {:error, :not_found}

  def attachment_changeset(struct, attrs) do
    struct
    |> cast(%{}, [])
    |> cast_attachments(attrs, [:file])
    |> validate_required([:file])
  end
end
