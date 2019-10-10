defmodule SiresTaskApiWeb.TaskEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  describe "GET /api/v1/tasks" do
    setup %{conn: conn} do
      user = insert!(:user)
      {:ok, user: user, conn: conn |> sign_as(user)}
    end

    defp assert_index(conn, params, task_to_assert, task_to_refute) do
      response = conn |> get("/api/v1/tasks?#{params}") |> json_response(200)
      ids = response["tasks"] |> Enum.map(& &1["id"])
      assert task_to_assert.id in ids
      refute task_to_refute.id in ids
      assert response["total_count"] == 1
    end

    test "list available tasks", ctx do
      task = insert!(:task)
      other_task = insert!(:task)
      insert!(:project_member, project: task.project, user: ctx.user, role: "guest")
      ctx.conn |> assert_index("", task, other_task)
    end

    test "filter by search string", ctx do
      project = insert!(:project)
      task = insert!(:task, project: project, name: "Try to find me")
      other_task = insert!(:task, project: project)
      insert!(:project_member, project: project, user: ctx.user, role: "guest")
      ctx.conn |> assert_index("search=find", task, other_task)
    end

    test "filter by project", ctx do
      task = insert!(:task)
      other_task = insert!(:task)
      insert!(:project_member, project: task.project, user: ctx.user, role: "guest")
      insert!(:project_member, project: other_task.project, user: ctx.user, role: "guest")
      ctx.conn |> assert_index("project_id=#{task.project.id}", task, other_task)
    end

    test "filter by done flag", ctx do
      project = insert!(:project)
      task = insert!(:task, project: project, done: false)
      other_task = insert!(:task, project: project, done: true)
      insert!(:project_member, project: project, user: ctx.user, role: "guest")
      ctx.conn |> assert_index("done=false", task, other_task)
    end

    test "filter by finish date", ctx do
      project = insert!(:project)
      now = DateTime.utc_now() |> DateTime.truncate(:second)
      task = insert!(:task, project: project, finish_time: now)
      other_task = insert!(:task, project: project, finish_time: now |> DateTime.add(86400))
      insert!(:project_member, project: project, user: ctx.user, role: "guest")
      date = now |> DateTime.to_date() |> Date.to_iso8601()
      ctx.conn |> assert_index("finish_date=#{date}", task, other_task)

      ctx.conn |> get("/api/v1/tasks?finish_date=12345") |> json_response(422)
    end

    test "filter hot tasks", ctx do
      project = insert!(:project)
      now = DateTime.utc_now() |> DateTime.truncate(:second)
      task = insert!(:task, project: project, finish_time: now |> DateTime.add(6 * 86400))
      other_task = insert!(:task, project: project, finish_time: now |> DateTime.add(8 * 86400))
      insert!(:project_member, project: project, user: ctx.user, role: "guest")
      ctx.conn |> assert_index("hot=true", task, other_task)
    end

    test "filter by member role", ctx do
      project = insert!(:project)
      task = insert!(:task, project: project)
      other_task = insert!(:task, project: project)
      insert!(:project_member, project: project, user: ctx.user, role: "guest")
      insert!(:task_member, task: task, user: ctx.user, role: "co-responsible")
      ctx.conn |> assert_index("role=co-responsible", task, other_task)
    end

    test "filter by tags", ctx do
      project = insert!(:project)
      tag = build(:tag)
      task = insert!(:task, project: project, tags: [tag])
      other_task = insert!(:task, project: project)
      insert!(:project_member, project: project, user: ctx.user, role: "guest")
      ctx.conn |> assert_index("tags[]=#{tag.name}", task, other_task)
    end

    test "filter only top level tasks", ctx do
      ref = insert!(:task_reference)
      insert!(:project_member, project: ref.parent_task.project, user: ctx.user, role: "guest")
      ctx.conn |> assert_index("top_level=true", ref.parent_task, ref.child_task)
    end

    test "filter only subtasks", ctx do
      ref = insert!(:task_reference)
      insert!(:project_member, project: ref.child_task.project, user: ctx.user, role: "guest")
      ctx.conn |> assert_index("top_level=false", ref.child_task, ref.parent_task)
    end

    test "list tasks as admin", ctx do
      admin = insert!(:admin)
      task = insert!(:task)
      other_task = insert!(:task)

      response = ctx.conn |> sign_as(admin) |> get("/api/v1/tasks") |> json_response(200)

      ids = response["tasks"] |> Enum.map(& &1["id"])
      assert task.id in ids
      assert other_task.id in ids
      assert response["total_count"] == 2
    end
  end

  describe "GET /api/v1/tasks/calendar" do
    setup %{conn: conn} do
      user = insert!(:user)
      {:ok, conn: conn |> sign_as(user), user: user}
    end

    test "show calendar for specified month", ctx do
      {:ok, dt1, _} = DateTime.from_iso8601("2019-03-15T17:40:21Z")
      task1 = insert!(:task, finish_time: dt1)
      insert!(:project_member, project: task1.project, user: ctx.user)

      {:ok, dt2, _} = DateTime.from_iso8601("2019-03-29T14:30:00Z")
      task2 = insert!(:task, finish_time: dt2)
      insert!(:project_member, project: task2.project, user: ctx.user)

      {:ok, dt3, _} = DateTime.from_iso8601("2019-03-29T20:25:00Z")
      task3 = insert!(:task, finish_time: dt3)
      insert!(:project_member, project: task3.project, user: ctx.user)

      {:ok, dt4, _} = DateTime.from_iso8601("2019-04-01T00:00:00Z")
      task4 = insert!(:task, finish_time: dt4)
      insert!(:project_member, project: task4.project, user: ctx.user)

      {:ok, dt5, _} = DateTime.from_iso8601("2019-02-28T23:59:59Z")
      task5 = insert!(:task, finish_time: dt5)
      insert!(:project_member, project: task5.project, user: ctx.user)

      response = ctx.conn |> get("/api/v1/tasks/calendar?year=2019&month=3") |> json_response(200)
      assert response |> get_in(["calendar", "15", Access.at(0), "id"]) == task1.id
      assert response |> get_in(["calendar", "29", Access.at(0), "id"]) == task2.id
      assert response |> get_in(["calendar", "29", Access.at(1), "id"]) == task3.id
      refute response["calendar"]["1"]
      refute response["calendar"]["28"]
    end

    test "fail to show calendar with wrong params", ctx do
      ctx.conn |> get("/api/v1/tasks/calendar?year=2019") |> json_response(422)
      ctx.conn |> get("/api/v1/tasks/calendar?month=1") |> json_response(422)
      ctx.conn |> get("/api/v1/tasks/calendar?year=2019&month=13") |> json_response(422)
      ctx.conn |> get("/api/v1/tasks/calendar?year=0&month=1") |> json_response(422)
      ctx.conn |> get("/api/v1/tasks/calendar?year=wrong&month=wrong") |> json_response(422)
    end
  end

  describe "GET /api/v1/tasks/:id" do
    setup %{conn: conn} do
      user = insert!(:user)
      task = insert!(:task)
      {:ok, user: user, conn: conn |> sign_as(user), task: task}
    end

    test "show task", ctx do
      insert!(:project_member, user: ctx.user, project: ctx.task.project, role: "guest")
      response = ctx.conn |> get("/api/v1/tasks/#{ctx.task.id}") |> json_response(200)
      assert response["task"]["id"] == ctx.task.id
    end

    test "show task for global admin", ctx do
      admin = insert!(:admin)
      conn = ctx.conn |> sign_as(admin)
      response = conn |> get("/api/v1/tasks/#{ctx.task.id}") |> json_response(200)
      assert response["task"]["id"] == ctx.task.id
    end

    test "fail to show task without permissions", ctx do
      ctx.conn |> get("/api/v1/tasks/#{ctx.task.id}") |> json_response(403)
    end

    test "fail to show missing task", ctx do
      ctx.conn |> get("/api/v1/tasks/9999999999") |> json_response(404)
    end
  end

  describe "POST /api/v1/tasks" do
    setup %{conn: conn} do
      user = insert!(:user)
      {:ok, user: user, conn: conn |> sign_as(user)}
    end

    test "create task", ctx do
      project = insert!(:project)
      insert!(:project_member, user: ctx.user, project: project)
      tag = insert!(:tag)
      now = DateTime.utc_now() |> DateTime.truncate(:second)
      upload = build(:upload)

      params = %{
        project_id: project.id,
        name: "Some task",
        description: "Do something",
        start_time: now |> DateTime.to_iso8601(),
        finish_time: now |> DateTime.add(1) |> DateTime.to_iso8601(),
        tag_ids: [tag.id],
        attachments: [%{file: upload}]
      }

      response =
        ctx.conn
        |> post("/api/v1/tasks", task: params)
        |> json_response(201)

      assert response["task"]["project"]["id"] == project.id
      assert response["task"]["name"] == "Some task"
      assert response["task"]["description"] == "Do something"
      assert response["task"]["start_time"] == params.start_time
      assert response["task"]["finish_time"] == params.finish_time
      assert response["task"]["tags"] |> List.first() |> Map.fetch!("id") == tag.id
      assert url = get_in(response, ["task", "attachments", Access.at(0), "last_version", "url"])
      assert File.read!("." <> url) == File.read!(upload.path)
    end

    test "fail to create task as guest", ctx do
      project = insert!(:project)
      insert!(:project_member, user: ctx.user, project: project, role: "guest")

      ctx.conn
      |> post("/api/v1/tasks", task: %{project_id: project.id, name: "Some task"})
      |> json_response(403)
    end

    test "fail to create task in a missing project", ctx do
      ctx.conn
      |> post("/api/v1/tasks", task: %{project_id: 9_999_999_999, name: "Some task"})
      |> json_response(404)
    end
  end

  describe "PUT /api/v1/tasks" do
    test "update task", ctx do
      user = insert!(:user)
      task = insert!(:task, tags: [build(:tag)])
      insert!(:project_member, user: user, project: task.project)
      insert!(:task_member, user: user, task: task, role: "assignator")
      tag = insert!(:tag)
      upload = build(:upload)

      params = %{
        name: "New name",
        description: "New description",
        start_time: task.start_time |> DateTime.add(3600) |> DateTime.to_iso8601(),
        finish_time: task.finish_time |> DateTime.add(3600) |> DateTime.to_iso8601(),
        tag_ids: [tag.id],
        attachments: [%{file: upload}]
      }

      response =
        ctx.conn
        |> sign_as(user)
        |> put("/api/v1/tasks/#{task.id}", task: params)
        |> json_response(200)

      assert response["task"]["name"] == params.name
      assert response["task"]["description"] == params.description
      assert response["task"]["start_time"] == params.start_time
      assert response["task"]["finish_time"] == params.finish_time
      assert response["task"]["tags"] |> Enum.map(& &1["id"]) == [tag.id]
      assert url = get_in(response, ["task", "attachments", Access.at(0), "last_version", "url"])
      assert File.read!("." <> url) == File.read!(upload.path)
    end

    test "update task as project admin", ctx do
      user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, user: user, project: task.project, role: "admin")

      ctx.conn
      |> sign_as(user)
      |> put("/api/v1/tasks/#{task.id}", task: %{description: "New description"})
      |> json_response(200)
    end

    test "update task as global admin", ctx do
      admin = insert!(:admin)
      task = insert!(:task)

      ctx.conn
      |> sign_as(admin)
      |> put("/api/v1/tasks/#{task.id}", task: %{description: "New description"})
      |> json_response(200)
    end

    test "fail to update task without permissions", ctx do
      user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, user: user, project: task.project)

      ctx.conn
      |> sign_as(user)
      |> put("/api/v1/tasks/#{task.id}", task: %{description: "New description"})
      |> json_response(403)
    end

    test "fail to update task with wrong params", ctx do
      user = insert!(:user)
      task = insert!(:task)
      insert!(:project_member, user: user, project: task.project)
      insert!(:task_member, user: user, task: task, role: "assignator")

      ctx.conn
      |> sign_as(user)
      |> put("/api/v1/tasks/#{task.id}", task: %{start_time: "wrong"})
      |> json_response(422)
    end

    test "fail to update missing task", ctx do
      user = insert!(:user)

      ctx.conn
      |> sign_as(user)
      |> put("/api/v1/tasks/9999999999", task: %{description: "New description"})
      |> json_response(404)
    end
  end

  describe "POST /api/v1/tasks/:id/mark_(un)done" do
    defp toggle_done_on_and_off(conn, task) do
      conn
      |> post("/api/v1/tasks/#{task.id}/mark_done")
      |> json_response(200)
      |> get_in(~w(task done))
      |> assert()

      conn
      |> post("/api/v1/tasks/#{task.id}/mark_undone")
      |> json_response(200)
      |> get_in(~w(task done))
      |> refute()
    end

    test "toggle task done off and on as task responsible member", ctx do
      task = insert!(:task)
      user = insert!(:user)
      insert!(:project_member, project: task.project, user: user)
      insert!(:task_member, task: task, user: user, role: "responsible")
      ctx.conn |> sign_as(user) |> toggle_done_on_and_off(task)
    end

    test "toggle task done off and on as task co-responsible member", ctx do
      task = insert!(:task)
      user = insert!(:user)
      insert!(:project_member, project: task.project, user: user)
      insert!(:task_member, task: task, user: user, role: "co-responsible")
      ctx.conn |> sign_as(user) |> toggle_done_on_and_off(task)
    end

    test "toggle task done off and on as task assignator", ctx do
      task = insert!(:task)
      user = insert!(:user)
      insert!(:project_member, project: task.project, user: user)
      insert!(:task_member, task: task, user: user, role: "assignator")
      ctx.conn |> sign_as(user) |> toggle_done_on_and_off(task)
    end

    test "toggle task done off and on as project admin", ctx do
      task = insert!(:task)
      user = insert!(:user)
      insert!(:project_member, project: task.project, user: user, role: "admin")
      ctx.conn |> sign_as(user) |> toggle_done_on_and_off(task)
    end

    test "toggle task done off and on as global admin", ctx do
      task = insert!(:task)
      admin = insert!(:admin)
      ctx.conn |> sign_as(admin) |> toggle_done_on_and_off(task)
    end

    test "fail to mark task done without permission", ctx do
      task = insert!(:task)
      user = insert!(:user)

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tasks/#{task.id}/mark_done")
      |> json_response(403)
    end

    test "fail to mark missing task done", ctx do
      user = insert!(:user)

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tasks/9999999999/mark_done")
      |> json_response(404)
    end
  end

  describe "DELETE /api/v1/tasks/:id" do
    setup %{conn: conn} do
      user = insert!(:user)
      {:ok, user: user, conn: conn |> sign_as(user), task: insert!(:task)}
    end

    test "delete task as task assignator", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user)
      insert!(:task_member, task: ctx.task, user: ctx.user, role: "assignator")

      ctx.conn |> delete("/api/v1/tasks/#{ctx.task.id}") |> json_response(200)
      ctx.conn |> get("/api/v1/tasks/#{ctx.task.id}") |> json_response(404)
    end

    test "delete task as project admin", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user, role: "admin")

      ctx.conn |> delete("/api/v1/tasks/#{ctx.task.id}") |> json_response(200)
      ctx.conn |> get("/api/v1/tasks/#{ctx.task.id}") |> json_response(404)
    end

    test "delete task as global admin", ctx do
      admin = insert!(:admin)
      conn = ctx.conn |> sign_as(admin)

      conn |> delete("/api/v1/tasks/#{ctx.task.id}") |> json_response(200)
      conn |> get("/api/v1/tasks/#{ctx.task.id}") |> json_response(404)
    end

    test "fail to delete task without permissions", ctx do
      insert!(:project_member, project: ctx.task.project, user: ctx.user)
      ctx.conn |> delete("/api/v1/tasks/#{ctx.task.id}") |> json_response(403)
    end

    test "fail to delete missing task", ctx do
      ctx.conn |> delete("/api/v1/tasks/9999999999") |> json_response(404)
    end
  end
end
