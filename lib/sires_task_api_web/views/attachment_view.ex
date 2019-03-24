defmodule SiresTaskApiWeb.AttachmentView do
  use SiresTaskApiWeb, :view

  def attachment(attachment) do
    attachment
    |> Map.take([:file, :inserted_at])
  end
end
