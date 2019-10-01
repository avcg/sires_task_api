defmodule SiresTaskApiWeb.Task.Member.RoleEnpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  describe "PUT /api/v1/tasks/:task_id/members/roles/:role" do
    test "set members for the role", ctx do
      task = insert!(:task)

      # This is the one who makes the request. His role shouldn't change.
      assignator = insert!(:user)
      insert!(:project_member, project: task.project, user: assignator)
      insert!(:task_member, task: task, user: assignator, role: "assignator")

      # This one should lost his role.
      old_responsible = insert!(:user)
      insert!(:project_member, project: task.project, user: old_responsible)
      insert!(:task_member, task: task, user: old_responsible, role: "responsible")

      # This one should become responsible instead of co-responsible.
      old_coresponsible = insert!(:user)
      insert!(:project_member, project: task.project, user: old_coresponsible)
      insert!(:task_member, task: task, user: old_coresponsible, role: "co-responsible")

      # This is not in the task but should become responsible.
      new_user = insert!(:user)
      insert!(:project_member, project: task.project, user: new_user)

      user_ids = [old_coresponsible.id, new_user.id]

      response =
        ctx.conn
        |> sign_as(assignator)
        |> put("/api/v1/tasks/#{task.id}/members/roles/responsible", user_ids: user_ids)
        |> json_response(200)

      ids = response["members"] |> Enum.map(& &1["user"]["id"])
      refute old_responsible.id in ids
      assert old_coresponsible.id in ids
      assert new_user.id in ids

      response =
        ctx.conn
        |> sign_as(assignator)
        |> get("/api/v1/tasks/#{task.id}")
        |> json_response(200)

      members = response["task"]["members"]
      assert members |> Enum.count() == 3
      refute members |> Enum.find(&(&1["user"]["id"] == old_responsible.id))

      assert Enum.find(members, fn member ->
               member["user"]["id"] == assignator.id && member["role"] == "assignator"
             end)

      assert Enum.find(members, fn member ->
               member["user"]["id"] == old_coresponsible.id && member["role"] == "responsible"
             end)

      assert Enum.find(members, fn member ->
               member["user"]["id"] == new_user.id && member["role"] == "responsible"
             end)
    end

    test "fail on wrong role", ctx do
      task = insert!(:task)
      assignator = insert!(:user)
      insert!(:project_member, project: task.project, user: assignator)
      insert!(:task_member, task: task, user: assignator, role: "assignator")

      ctx.conn
      |> sign_as(assignator)
      |> put("/api/v1/tasks/#{task.id}/members/roles/wrong", user_ids: [])
      |> json_response(422)
    end

    test "fail on missing task", ctx do
      user = insert!(:user)

      ctx.conn
      |> sign_as(user)
      |> put("/api/v1/tasks/01234/members/roles/responsible", user_ids: [])
      |> json_response(404)
    end

    test "fail when not authorized", ctx do
      task = insert!(:task)
      user = insert!(:user)

      ctx.conn
      |> sign_as(user)
      |> put("/api/v1/tasks/#{task.id}/members/roles/responsible", user_ids: [])
      |> json_response(403)
    end

    test "fail when user is not in the project", ctx do
      task = insert!(:task)
      assignator = insert!(:user)
      insert!(:project_member, project: task.project, user: assignator)
      insert!(:task_member, task: task, user: assignator, role: "assignator")

      ctx.conn
      |> sign_as(assignator)
      |> put("/api/v1/tasks/#{task.id}/members/roles/responsible", user_ids: [insert!(:user).id])
      |> json_response(422)
    end
  end
end
