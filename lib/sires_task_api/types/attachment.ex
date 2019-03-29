defmodule SiresTaskApi.Attachment do
  @behaviour Ecto.Type

  def type, do: :map

  def cast(%Plug.Upload{} = upload), do: {:ok, upload}
  def cast(_), do: :error

  def load(data) when is_map(data) do
    data =
      for {key, value} <- data do
        {String.to_existing_atom(key), value}
      end

    {:ok, struct!(Plug.Upload, data)}
  end

  def dump(%Plug.Upload{} = upload), do: {:ok, Map.from_struct(upload)}
  def dump(_), do: :error
end
