defmodule SiresTaskApiWeb.Task.ReferenceEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  describe "POST /api/v1/tasks/:task_id/references" do
    setup %{conn: conn} do
      user = insert!(:user)
      project = insert!(:project)
      task = insert!(:task, project: project)
      other_task = insert!(:task, project: project)

      {:ok, user: user, conn: conn |> sign_as(user), task: task, other_task: other_task}
    end

    defp add_reference(conn, task, other_task) do
      params = %{task_id: other_task.id, reference_type: "subtask"}

      response =
        conn
        |> post("/api/v1/tasks/#{task.id}/references", reference: params)
        |> json_response(201)

      assert response["reference"]["reference_type"] == "subtask"
      assert response["reference"]["task"]["id"] == other_task.id
    end

    test "add reference to task as task assignator", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user)
      insert!(:task_member, task: ctx.task, user: ctx.user, role: "assignator")
      ctx.conn |> add_reference(ctx.task, ctx.other_task)
    end

    test "add reference to task as project admin", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")
      ctx.conn |> add_reference(ctx.task, ctx.other_task)
    end

    test "add reference to task as global admin", ctx do
      admin = insert!(:admin)
      ctx.conn |> sign_as(admin) |> add_reference(ctx.task, ctx.other_task)
    end

    test "fail to add task without permission", ctx do
      params = %{task_id: ctx.other_task.id, reference_type: "subtask"}

      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/references", reference: params)
      |> json_response(403)
    end

    test "fail to add reference twice", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")

      insert!(:task_reference,
        parent_task: ctx.task,
        child_task: ctx.other_task,
        reference_type: "subtask"
      )

      params = %{task_id: ctx.other_task.id, reference_type: "blocker"}

      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/references", reference: params)
      |> json_response(422)
    end

    test "fail to add reference with wrong params", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")
      params = %{task_id: ctx.other_task.id, reference_type: "wrong"}

      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/references", reference: params)
      |> json_response(422)
    end

    test "fail to add reference to a task from another project", ctx do
      other_task = insert!(:task)
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")
      insert!(:project_member, project: other_task.project, user: ctx.user, role: "admin")
      params = %{task_id: other_task.id, reference_type: "blocker"}

      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/references", reference: params)
      |> json_response(422)
    end

    test "fail to add reference to a non-existing task", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")
      params = %{task_id: 9_999_999_999, reference_type: "subtask"}

      ctx.conn
      |> post("/api/v1/tasks/#{ctx.task.id}/references", reference: params)
      |> json_response(404)
    end

    test "fail to add reference for a non-existing task", ctx do
      params = %{task_id: ctx.other_task.id, reference_type: "subtask"}

      ctx.conn
      |> post("/api/v1/tasks/9999999999/references", reference: params)
      |> json_response(404)
    end
  end

  describe "DELETE /api/v1/tasks/:task_id/references/:id" do
    defp ensure_not_a_reference(conn, reference) do
      response =
        conn
        |> get("/api/v1/tasks/#{reference.parent_task_id}")
        |> json_response(200)

      response["task"]["references"]
      |> List.wrap()
      |> Enum.find(&(&1["id"] == reference.child_task_id))
      |> refute()
    end

    setup %{conn: conn} do
      user = insert!(:user)
      reference = insert!(:task_reference)
      {:ok, user: user, conn: conn |> sign_as(user), reference: reference}
    end

    test "remove task reference as task assignator", ctx do
      insert!(:project_member, project: ctx.reference.parent_task.project, user: ctx.user)
      insert!(:task_member, task: ctx.reference.parent_task, user: ctx.user, role: "assignator")
      %{parent_task_id: parent_id, child_task_id: child_id} = ctx.reference

      ctx.conn
      |> delete("/api/v1/tasks/#{parent_id}/references/#{child_id}")
      |> json_response(200)

      ctx.conn |> ensure_not_a_reference(ctx.reference)
    end

    test "remove tak reference as project admin", ctx do
      insert!(:project_member,
        project: ctx.reference.parent_task.project,
        user: ctx.user,
        role: "admin"
      )

      %{parent_task_id: parent_id, child_task_id: child_id} = ctx.reference

      ctx.conn
      |> delete("/api/v1/tasks/#{parent_id}/references/#{child_id}")
      |> json_response(200)

      ctx.conn |> ensure_not_a_reference(ctx.reference)
    end

    test "remove task reference as global admin", ctx do
      admin = insert!(:admin)
      conn = ctx.conn |> sign_as(admin)

      %{parent_task_id: parent_id, child_task_id: child_id} = ctx.reference

      conn
      |> delete("/api/v1/tasks/#{parent_id}/references/#{child_id}")
      |> json_response(200)

      conn |> ensure_not_a_reference(ctx.reference)
    end

    test "fail to remove task reference without permission", ctx do
      %{parent_task_id: parent_id, child_task_id: child_id} = ctx.reference

      ctx.conn
      |> delete("/api/v1/tasks/#{parent_id}/references/#{child_id}")
      |> json_response(403)
    end

    test "fail to remove missing task reference", ctx do
      insert!(:project_member, project: ctx.reference.parent_task.project, user: ctx.user)
      insert!(:task_member, task: ctx.reference.parent_task, user: ctx.user, role: "assignator")
      other_task = insert!(:task)

      ctx.conn
      |> delete("/api/v1/tasks/#{ctx.reference.parent_task_id}/references/#{other_task.id}")
      |> json_response(404)
    end

    test "fail to remove task reference from non-existing task", ctx do
      ctx.conn
      |> delete("/api/v1/tasks/9999999999/references/#{ctx.reference.child_task_id}")
      |> json_response(404)
    end
  end
end
