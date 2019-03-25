defmodule SiresTaskApiWeb.Task.MemberEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  describe "POST /api/v1/tasks/:task_id/members" do
    test "add member to task as task assignor", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user)
      insert!(:project_member, project: task.project, user: other_user)
      insert!(:task_member, task: task, user: user, role: "assignor")
      params = %{user_id: other_user.id, role: "responsible"}

      response =
        ctx.conn
        |> sign_as(user)
        |> post("/api/v1/tasks/#{task.id}/members", member: params)
        |> json_response(201)

      assert response["member"]["role"] == "responsible"
      assert response["member"]["user"]["id"] == other_user.id
    end

    test "add member to task as project admin", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user, role: "admin")
      insert!(:project_member, project: task.project, user: other_user)
      params = %{user_id: other_user.id, role: "observer"}

      response =
        ctx.conn
        |> sign_as(user)
        |> post("/api/v1/tasks/#{task.id}/members", member: params)
        |> json_response(201)

      assert response["member"]["role"] == "observer"
      assert response["member"]["user"]["id"] == other_user.id
    end

    test "add member to task as global admin", ctx do
      admin = insert!(:admin)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: other_user)
      params = %{user_id: other_user.id, role: "co-responsible"}

      response =
        ctx.conn
        |> sign_as(admin)
        |> post("/api/v1/tasks/#{task.id}/members", member: params)
        |> json_response(201)

      assert response["member"]["role"] == "co-responsible"
      assert response["member"]["user"]["id"] == other_user.id
    end

    test "fail to add member without permission", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user)
      params = %{user_id: other_user.id, role: "responsible"}

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tasks/#{task.id}/members", member: params)
      |> json_response(403)
    end

    test "fail to add member twice with the same role", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user, role: "admin")
      insert!(:project_member, project: task.project, user: other_user)
      insert!(:task_member, task: task, user: other_user, role: "assignor")
      params = %{user_id: other_user.id, role: "assignor"}

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tasks/#{task.id}/members", member: params)
      |> json_response(422)
    end

    test "fail to add member with wrong params", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user, role: "admin")
      insert!(:project_member, project: task.project, user: other_user)
      params = %{user_id: other_user.id, role: "wrong"}

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tasks/#{task.id}/members", member: params)
      |> json_response(422)
    end

    test "fail to add someone who is not a project member as task member", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user, role: "admin")
      params = %{user_id: other_user.id, role: "responsible"}

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tasks/#{task.id}/members", member: params)
      |> json_response(422)
    end

    test "fail to add a guest project member as task member", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user, role: "admin")
      insert!(:project_member, project: task.project, user: other_user, role: "guest")
      params = %{user_id: other_user.id, role: "responsible"}

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tasks/#{task.id}/members", member: params)
      |> json_response(422)
    end

    test "fail to add non-existing user as member", ctx do
      user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user, role: "admin")
      params = %{user_id: 9_999_999_999, role: "observer"}

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tasks/#{task.id}/members", member: params)
      |> json_response(404)
    end

    test "fail to add member to a non-existing project", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      params = %{user_id: other_user.id, role: "responsible"}

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tasks/9999999999/members", member: params)
      |> json_response(404)
    end
  end

  describe "DELETE /api/v1/tasks/:task_id/members/:id" do
    def ensure_not_a_member(conn, task, user, other_user, role) do
      response =
        conn
        |> sign_as(user)
        |> get("/api/v1/tasks/#{task.id}")
        |> json_response(200)

      response["task"]["members"]
      |> Enum.find(&(&1["id"] == other_user.id && &1["role"] == role))
      |> refute()
    end

    test "remove member role as task assignor", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user)
      insert!(:project_member, project: task.project, user: other_user)
      insert!(:task_member, task: task, user: user, role: "assignor")
      insert!(:task_member, task: task, user: other_user, role: "responsible")

      ctx.conn
      |> sign_as(user)
      |> delete("/api/v1/tasks/#{task.id}/members/#{other_user.id}?role=responsible")
      |> json_response(200)

      ctx.conn |> ensure_not_a_member(task, user, other_user, "responsible")
    end

    test "remove member role as project admin", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user, role: "admin")
      insert!(:project_member, project: task.project, user: other_user)
      insert!(:task_member, task: task, user: other_user, role: "responsible")

      ctx.conn
      |> sign_as(user)
      |> delete("/api/v1/tasks/#{task.id}/members/#{other_user.id}?role=responsible")
      |> json_response(200)

      ctx.conn |> ensure_not_a_member(task, user, other_user, "responsible")
    end

    test "remove member role as global admin", ctx do
      admin = insert!(:admin)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: other_user)
      insert!(:task_member, task: task, user: other_user, role: "responsible")

      ctx.conn
      |> sign_as(admin)
      |> delete("/api/v1/tasks/#{task.id}/members/#{other_user.id}?role=responsible")
      |> json_response(200)

      ctx.conn |> ensure_not_a_member(task, admin, other_user, "responsible")
    end

    test "fail to remove member without admin permissions", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user)
      insert!(:project_member, project: task.project, user: other_user)
      insert!(:task_member, task: task, user: other_user, role: "responsible")

      ctx.conn
      |> sign_as(user)
      |> delete("/api/v1/tasks/#{task.id}/members/#{other_user.id}?role=responsible")
      |> json_response(403)
    end

    test "fail to remove member with role he doesn't have", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user, role: "admin")
      insert!(:project_member, project: task.project, user: other_user)
      insert!(:task_member, task: task, user: other_user, role: "observer")

      ctx.conn
      |> sign_as(user)
      |> delete("/api/v1/tasks/#{task.id}/members/#{other_user.id}?role=responsible")
      |> json_response(404)
    end

    test "fail to remove user who is not a task member", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, project: task.project, user: user, role: "admin")
      insert!(:project_member, project: task.project, user: other_user)

      ctx.conn
      |> sign_as(user)
      |> delete("/api/v1/tasks/#{task.id}/members/#{other_user.id}?role=responsible")
      |> json_response(404)
    end

    test "fail to remove member from non-existing project", ctx do
      user = insert!(:user)
      other_user = insert!(:user)

      ctx.conn
      |> sign_as(user)
      |> delete("/api/v1/tasks/9999999999/members/#{other_user.id}?role=responsible")
      |> json_response(404)
    end
  end
end
