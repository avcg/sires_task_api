defmodule SiresTaskApiWeb.Task.AttachmentEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  setup %{conn: conn} do
    user = insert!(:user)
    conn = conn |> sign_as(user)
    task = insert!(:task)

    {:ok, user: user, conn: conn, task: task}
  end

  describe "POST /api/v1/tasks/:task_id/attachments" do
    test "add attachment as task assignator", ctx do
      insert!(:task_member, task: ctx.task, user: ctx.user, role: "assignator")
      upload = build(:upload)

      response =
        ctx.conn
        |> post("/api/v1/tasks/#{ctx.task.id}/attachments", %{attachment: %{file: upload}})
        |> json_response(201)

      url = response["attachment"]["last_version"]["url"]
      assert File.read!("." <> url) == File.read!(upload.path)
    end

    test "add attachment as project admin", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")
      upload = build(:upload)

      response =
        ctx.conn
        |> post("/api/v1/tasks/#{ctx.task.id}/attachments", %{attachment: %{file: upload}})
        |> json_response(201)

        url = response["attachment"]["last_version"]["url"]
      assert File.read!("." <> url) == File.read!(upload.path)
    end

    test "add attachment as global admin", ctx do
      admin = insert!(:admin)
      upload = build(:upload)

      response =
        ctx.conn
        |> sign_as(admin)
        |> post("/api/v1/tasks/#{ctx.task.id}/attachments", %{attachment: %{file: upload}})
        |> json_response(201)

        url = response["attachment"]["last_version"]["url"]
      assert File.read!("." <> url) == File.read!(upload.path)
    end

    test "fail to add attachment without permission", ctx do
      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/attachments", %{attachment: %{file: build(:upload)}})
      |> json_response(403)
    end

    test "fail to add attachment with wrong params", ctx do
      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/attachments", %{attachment: %{file: "wrong"}})
      |> json_response(422)
    end

    test "fail to add attachment to missing task", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")

      ctx.conn
      |> post("/api/v1/tasks/9999999999/attachments", %{attachment: %{file: build(:upload)}})
      |> json_response(404)
    end
  end
end
