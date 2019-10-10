defmodule SiresTaskApiWeb.Task.AttachmentController do
  use SiresTaskApiWeb, :controller
  alias SiresTaskApi.Task

  def create(conn, params) do
    with {:ok, %{attachment: attachment}} <- Task.AddAttachment |> run(conn, params) do
      conn |> put_status(:created) |> render(:show, attachment: attachment)
    end
  end
end
