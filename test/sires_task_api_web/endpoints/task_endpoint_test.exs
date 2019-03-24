defmodule SiresTaskApiWeb.TaskEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  describe "POST /api/v1/tasks" do
    test "create task", ctx do
      user = insert!(:user)
      project = insert!(:project)
      insert!(:project_member, user: user, project: project)
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      params = %{
        project_id: project.id,
        name: "Some task",
        description: "Do something",
        start_time: now |> DateTime.to_iso8601(),
        finish_time: now |> DateTime.add(1) |> DateTime.to_iso8601()
      }

      response =
        ctx.conn
        |> sign_as(user)
        |> post("/api/v1/tasks", task: params)
        |> json_response(201)

      assert response["task"]["project"]["id"] == project.id
      assert response["task"]["name"] == "Some task"
      assert response["task"]["description"] == "Do something"
      assert response["task"]["start_time"] == params.start_time
      assert response["task"]["finish_time"] == params.finish_time
    end

    test "fail to create task as guest", ctx do
      user = insert!(:user)
      project = insert!(:project)
      insert!(:project_member, user: user, project: project, role: "guest")

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tasks", task: %{project_id: project.id, name: "Some task"})
      |> json_response(403)
    end

    test "fail to create task in a missing project", ctx do
      user = insert!(:user)

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tasks", task: %{project_id: 9_999_999_999, name: "Some task"})
      |> json_response(404)
    end
  end
end
