defmodule SiresTaskApi.User.Avatar do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def transform(:thumb, _) do
    {:convert, "-thumbnail 100x100^ -gravity center -extent 100x100 -format jpg", :jpg}
  end

  def filename(version, _) do
    version
  end

  def storage_dir(_, {_, %{id: id}}) when not is_nil(id) do
    "uploads/avatars/#{id}"
  end
end
