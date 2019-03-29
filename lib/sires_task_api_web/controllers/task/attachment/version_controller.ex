defmodule SiresTaskApiWeb.Task.Attachment.VersionController do
  use SiresTaskApiWeb, :controller
  import Ecto.Query
  alias SiresTaskApi.{Repo, Task, TaskPolicy}

  plug SiresTaskApiWeb.Find,
       [
         schema: Task,
         assign: :task,
         param: :task_id,
         preload: [:project],
         policy: TaskPolicy,
         auth_action: :show
       ]
       when action == :index

  plug SiresTaskApiWeb.Find,
       [
         schema: Task.Attachment,
         assign: :attachment,
         param: :attachment_id,
         skip_authorization: true
       ]
       when action == :index

  def index(conn, _params) do
    if conn.assigns.attachment.task_id == conn.assigns.task.id do
      versions_query = Task.Attachment.Version |> order_by(desc: :inserted_at)
      preloads = [versions: {versions_query, [:attachment]}]
      attachment = conn.assigns.attachment |> Repo.preload(preloads)
      conn |> render(versions: attachment.versions)
    else
      {:error, :not_found}
    end
  end

  def create(conn, params) do
    with {:ok, %{upload_file: version}} <- Task.AddAttachmentVersion |> run(conn, params) do
      conn |> put_status(:created) |> render(:show, version: version)
    end
  end
end
