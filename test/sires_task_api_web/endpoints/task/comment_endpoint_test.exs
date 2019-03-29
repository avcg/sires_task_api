defmodule SiresTaskApiWeb.Task.CommentEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  describe "POST /api/v1/tasks/:task_id/comments" do
    setup %{conn: conn} do
      user = insert!(:user)
      task = insert!(:task)
      {:ok, user: user, conn: conn |> sign_as(user), task: task}
    end

    test "add comment to task as project guest", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "guest")
      upload = build(:upload)
      params = %{text: "Hello", attachments: [%{file: upload}]}

      response =
        ctx.conn
        |> post("/api/v1/tasks/#{ctx.task.id}/comments", comment: params)
        |> json_response(201)

      assert response["comment"]["text"] == "Hello"
      assert url = get_in(response, ["comment", "attachments", Access.at(0), "url"])
      assert File.read!("." <> url) == File.read!(upload.path)
    end

    test "fail to comment a task while not being a project member", ctx do
      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/comments", comment: %{text: "Hello"})
      |> json_response(403)
    end

    test "fail to add comment with wrong params", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user)

      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/comments", comment: %{text: nil})
      |> json_response(422)
    end

    test "fail to add comment to a non-existing task", ctx do
      ctx.conn
      |> post("/api/v1/tasks/9999999999/comments", comment: %{text: "Hello"})
      |> json_response(404)
    end
  end

  describe "PUT /api/v1/tasks/:task_id/comments/:id" do
    setup %{conn: conn} do
      user = insert!(:user)
      comment = insert!(:task_comment)
      {:ok, user: user, conn: conn |> sign_as(user), comment: comment}
    end

    @params %{text: "New text"}

    test "update task comment as its author", ctx do
      insert!(:project_member, project: ctx.comment.task.project, user: ctx.user)
      upload = build(:upload)
      params = %{text: "New text", attachments: [%{file: upload}]}

      response =
        ctx.conn
        |> sign_as(ctx.comment.author)
        |> put("/api/v1/tasks/#{ctx.comment.task_id}/comments/#{ctx.comment.id}", comment: params)
        |> json_response(200)

      assert response["comment"]["text"] == params.text
      assert url = get_in(response, ["comment", "attachments", Access.at(0), "url"])
      assert File.read!("." <> url) == File.read!(upload.path)
    end

    test "update task comment as project admin", ctx do
      insert!(:project_member, project: ctx.comment.task.project, user: ctx.user, role: "admin")

      ctx.conn
      |> put("/api/v1/tasks/#{ctx.comment.task_id}/comments/#{ctx.comment.id}", comment: @params)
      |> json_response(200)
    end

    test "update task comment as global admin", ctx do
      admin = insert!(:admin)
      conn = ctx.conn |> sign_as(admin)

      conn
      |> put("/api/v1/tasks/#{ctx.comment.task_id}/comments/#{ctx.comment.id}", comment: @params)
      |> json_response(200)
    end

    test "fail to update task comment without permission", ctx do
      insert!(:project_member, project: ctx.comment.task.project, user: ctx.user)

      ctx.conn
      |> put("/api/v1/tasks/#{ctx.comment.task_id}/comments/#{ctx.comment.id}", comment: @params)
      |> json_response(403)
    end

    test "fail to update comment with wrong params", ctx do
      insert!(:project_member, project: ctx.comment.task.project, user: ctx.user)
      params = %{text: nil}

      ctx.conn
      |> put("/api/v1/tasks/#{ctx.comment.task_id}/comments/#{ctx.comment.id}", comment: params)
      |> json_response(422)
    end

    test "fail to update missing task comment", ctx do
      insert!(:project_member, project: ctx.comment.task.project, user: ctx.user, role: "admin")
      other_comment = insert!(:task_comment)

      ctx.conn
      |> put("/api/v1/tasks/#{ctx.comment.task_id}/comments/#{other_comment.id}", comment: @params)
      |> json_response(404)
    end

    test "fail to update task comment from non-existing task", ctx do
      insert!(:project_member, project: ctx.comment.task.project, user: ctx.user, role: "admin")

      ctx.conn
      |> put("/api/v1/tasks/9999999999/comments/#{ctx.comment.id}", comment: @params)
      |> json_response(404)
    end
  end

  describe "DELETE /api/v1/tasks/:task_id/comments/:id" do
    setup %{conn: conn} do
      user = insert!(:user)
      comment = insert!(:task_comment)
      {:ok, user: user, conn: conn |> sign_as(user), comment: comment}
    end

    defp ensure_missing_comment(conn, comment) do
      response =
        conn
        |> get("/api/v1/tasks/#{comment.task_id}")
        |> json_response(200)

      refute response["task"]["comments"] |> List.wrap() |> Enum.find(&(&1["id"] == comment.id))
    end

    test "remove task comment as comment author", ctx do
      insert!(:project_member, project: ctx.comment.task.project, user: ctx.user)

      ctx.conn
      |> sign_as(ctx.comment.author)
      |> delete("/api/v1/tasks/#{ctx.comment.task_id}/comments/#{ctx.comment.id}")
      |> json_response(200)

      ctx.conn |> ensure_missing_comment(ctx.comment)
    end

    test "remove tak comment as project admin", ctx do
      insert!(:project_member, project: ctx.comment.task.project, user: ctx.user, role: "admin")

      ctx.conn
      |> delete("/api/v1/tasks/#{ctx.comment.task_id}/comments/#{ctx.comment.id}")
      |> json_response(200)

      ctx.conn |> ensure_missing_comment(ctx.comment)
    end

    test "remove task comment as global admin", ctx do
      admin = insert!(:admin)
      conn = ctx.conn |> sign_as(admin)

      conn
      |> delete("/api/v1/tasks/#{ctx.comment.task_id}/comments/#{ctx.comment.id}")
      |> json_response(200)

      conn |> ensure_missing_comment(ctx.comment)
    end

    test "fail to remove task comment without permission", ctx do
      insert!(:project_member, project: ctx.comment.task.project, user: ctx.user)

      ctx.conn
      |> delete("/api/v1/tasks/#{ctx.comment.task_id}/comments/#{ctx.comment.id}")
      |> json_response(403)
    end

    test "fail to remove missing task comment", ctx do
      insert!(:project_member, project: ctx.comment.task.project, user: ctx.user, role: "admin")
      other_comment = insert!(:task_comment)

      ctx.conn
      |> delete("/api/v1/tasks/#{ctx.comment.task_id}/comments/#{other_comment.id}")
      |> json_response(404)
    end

    test "fail to remove task comment from non-existing task", ctx do
      insert!(:project_member, project: ctx.comment.task.project, user: ctx.user, role: "admin")

      ctx.conn
      |> delete("/api/v1/tasks/9999999999/comments/#{ctx.comment.id}")
      |> json_response(404)
    end
  end
end
