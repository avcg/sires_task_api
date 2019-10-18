defmodule SiresTaskApiWeb.Task.AttachmentView do
  use SiresTaskApiWeb, :view
  alias SiresTaskApiWeb.Task.Attachment.VersionView

  def render("show.json", %{attachment: attachment}) do
    %{attachment: attachment(attachment)}
  end

  def attachment(%{id: id, versions: [version | _]}) do
    %{id: id, last_version: VersionView.version(version)}
  end
end
