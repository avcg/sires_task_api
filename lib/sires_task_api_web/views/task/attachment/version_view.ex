defmodule SiresTaskApiWeb.Task.Attachment.VersionView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApi.Task.Attachment.Version.Definition

  def render("index.json", %{versions: versions}) do
    %{versions: Enum.map(versions, &version/1)}
  end

  def render("show.json", %{version: version}) do
    %{version: version(version)}
  end

  def version(version) do
    version
    |> Map.take([:id, :inserted_at])
    |> Map.put(:url, Definition.url({version.file, version}, :original, signed: true))
  end
end
