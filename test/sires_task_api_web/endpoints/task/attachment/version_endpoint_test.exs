defmodule SiresTaskApiWeb.Task.Attachment.VersionEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  setup %{conn: conn} do
    user = insert!(:user)
    conn = conn |> sign_as(user)
    task = insert!(:task, attachments: [build(:task_attachment)])
    attachment = task.attachments |> List.first()
    version = attachment.versions |> List.first()

    {:ok, user: user, conn: conn, task: task, attachment: attachment, version: version}
  end

  describe "GET /api/v1/tasks/:task_id/attachments/:attachment_id/versions" do
    test "list attachment versions", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "guest")

      response =
        ctx.conn
        |> get("/api/v1/tasks/#{ctx.task.id}/attachments/#{ctx.attachment.id}/versions")
        |> json_response(200)

      assert response |> get_in(["versions", Access.at(0), "id"]) == ctx.version.id
    end

    test "list attachment versions as global admin", ctx do
      admin = insert!(:admin)

      response =
        ctx.conn
        |> sign_as(admin)
        |> get("/api/v1/tasks/#{ctx.task.id}/attachments/#{ctx.attachment.id}/versions")
        |> json_response(200)

      assert response |> get_in(["versions", Access.at(0), "id"]) == ctx.version.id
    end

    test "fail to list attachment versions without permissions", ctx do
      ctx.conn
      |> get("/api/v1/tasks/#{ctx.task.id}/attachments/#{ctx.attachment.id}/versions")
      |> json_response(403)
    end

    test "fail to list attachment versions for wrong attahment", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "guest")
      attachment = insert!(:task_attachment, task: build(:task, project: ctx.task.project))

      ctx.conn
      |> get("/api/v1/tasks/#{ctx.task.id}/attachments/#{attachment.id}/versions")
      |> json_response(404)
    end

    test "fail to list attachment versions for missing attachment", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "guest")

      ctx.conn
      |> get("/api/v1/tasks/#{ctx.task.id}/attachments/9999999999/versions")
      |> json_response(404)
    end

    test "fail to list attachment versions for missing task", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "guest")

      ctx.conn
      |> get("/api/v1/tasks/9999999999/attachments/#{ctx.attachment.id}/versions")
      |> json_response(404)
    end
  end

  describe "POST /api/v1/tasks/:task_id/attachments/:attachment_id/versions" do
    test "add attachment version as task assignor", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user)
      insert!(:task_member, task: ctx.task, user: ctx.user, role: "assignor")

      upload = build(:upload)
      params = %{version: %{file: upload}}

      response =
        ctx.conn
        |> post("/api/v1/tasks/#{ctx.task.id}/attachments/#{ctx.attachment.id}/versions", params)
        |> json_response(201)

      assert File.read!("." <> response["version"]["url"]) == File.read!(upload.path)
    end

    test "add attachment version as project admin", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")

      upload = build(:upload)
      params = %{version: %{file: upload}}

      response =
        ctx.conn
        |> post("/api/v1/tasks/#{ctx.task.id}/attachments/#{ctx.attachment.id}/versions", params)
        |> json_response(201)

      assert File.read!("." <> response["version"]["url"]) == File.read!(upload.path)
    end

    test "add attachment version as global admin", ctx do
      admin = insert!(:admin)
      upload = build(:upload)
      params = %{version: %{file: upload}}

      response =
        ctx.conn
        |> sign_as(admin)
        |> post("/api/v1/tasks/#{ctx.task.id}/attachments/#{ctx.attachment.id}/versions", params)
        |> json_response(201)

      assert File.read!("." <> response["version"]["url"]) == File.read!(upload.path)
    end

    test "fail to add attachment version without permission", ctx do
      params = %{version: %{file: build(:upload)}}

      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/attachments/#{ctx.attachment.id}/versions", params)
      |> json_response(403)
    end

    test "fail to add attachment version with wrong params", ctx do
      params = %{version: %{file: "wrong"}}

      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/attachments/#{ctx.attachment.id}/versions", params)
      |> json_response(422)
    end

    test "fail to add attachment version to wrong attachment", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")
      attachment = insert!(:task_attachment, task: build(:task, project: ctx.task.project))
      params = %{version: %{file: build(:upload)}}

      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/attachments/#{attachment.id}/versions", params)
      |> json_response(404)
    end

    test "fail to add attachment to missing attachment", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")
      params = %{version: %{file: build(:upload)}}

      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/attachments/9999999999/versions", params)
      |> json_response(404)
    end

    test "fail to add attachment to missing task", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")
      params = %{version: %{file: build(:upload)}}

      ctx.conn
      |> post("/api/v1/tasks/9999999999/attachments/#{ctx.attachment.id}/versions", params)
      |> json_response(404)
    end
  end
end
