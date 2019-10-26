defmodule SiresTaskApiWeb.ProjectEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  setup %{conn: conn} do
    user = insert!(:user)
    {:ok, conn: conn |> sign_as(user), user: user}
  end

  describe "GET /api/v1/projects" do
    test "list available projects", ctx do
      [project1, project2, project3, project4] = for _ <- 1..4, do: insert!(:project)
      project5 = insert!(:project, archived: true)
      insert!(:project_member, project: project1, user: ctx.user, role: "guest")
      insert!(:project_member, project: project2, user: ctx.user, role: "regular")
      insert!(:project_member, project: project3, user: ctx.user, role: "admin")
      insert!(:project_member, project: project5, user: ctx.user, role: "regular")

      response = ctx.conn |> get("/api/v1/projects?archived=false") |> json_response(200)
      ids = response["projects"] |> Enum.map(& &1["id"])

      assert project1.id in ids
      assert project2.id in ids
      assert project3.id in ids
      refute project4.id in ids
      refute project5.id in ids

      assert response["total_count"] == 3
    end

    test "pagination", ctx do
      for _ <- 1..3 do
        project = insert!(:project)
        insert!(:project_member, project: project, user: ctx.user)
      end

      response = ctx.conn |> get("/api/v1/projects?limit=2") |> json_response(200)
      assert response["total_count"] == 3
      assert response["projects"] |> Enum.count() == 2

      response = ctx.conn |> get("/api/v1/projects?limit=2&offset=2") |> json_response(200)
      assert response["total_count"] == 3
      assert response["projects"] |> Enum.count() == 1
    end

    test "list archived projects", ctx do
      project1 = insert!(:project, archived: true)
      project2 = insert!(:project, archived: false)
      insert!(:project_member, project: project1, user: ctx.user, role: "regular")
      insert!(:project_member, project: project2, user: ctx.user, role: "regular")

      response = ctx.conn |> get("/api/v1/projects?archived=true") |> json_response(200)
      ids = response["projects"] |> Enum.map(& &1["id"])

      assert project1.id in ids
      refute project2.id in ids
    end
  end

  describe "GET /api/v1/projects/:id" do
    test "show project", ctx do
      project = insert!(:project)
      insert!(:project_member, project: project, user: ctx.user)
      response = ctx.conn |> get("/api/v1/projects/#{project.id}") |> json_response(200)
      assert response["project"]["id"] == project.id
    end

    test "fail to show project for non-member", ctx do
      project = insert!(:project)
      ctx.conn |> get("/api/v1/projects/#{project.id}") |> json_response(403)
    end

    test "fail to show missing project", ctx do
      ctx.conn |> get("/api/v1/projects/9999999999") |> json_response(404)
    end
  end

  describe "POST /api/v1/projects" do
    test "create project", ctx do
      response =
        ctx.conn
        |> post("/api/v1/projects", project: %{name: "Hello"})
        |> json_response(201)

      assert response["project"]["creator"]["id"] == ctx.user.id
      assert response["project"]["editor"]["id"] == ctx.user.id

      assert member = response["project"]["members"] |> List.first()
      assert member["user"]["id"] == ctx.user.id
      assert member["role"] == "admin"
    end

    test "fail to create project with wrong params", ctx do
      ctx.conn
      |> post("/api/v1/projects", project: %{})
      |> json_response(422)
    end
  end

  describe "PUT /api/v1/projects/:id" do
    test "update project", ctx do
      project = insert!(:project)
      insert!(:project_member, project: project, user: ctx.user, role: "admin")

      response =
        ctx.conn
        |> put("/api/v1/projects/#{project.id}", project: %{name: "New name", archived: true})
        |> json_response(200)

      assert response["project"]["name"] == "New name"
      assert response["project"]["archived"] == true
      assert response["project"]["editor"]["id"] == ctx.user.id
    end

    test "fail to update project with wrong params", ctx do
      project = insert!(:project)
      insert!(:project_member, project: project, user: ctx.user, role: "admin")

      ctx.conn
      |> put("/api/v1/projects/#{project.id}", project: %{})
      |> json_response(422)
    end

    test "fail to update project without admin access", ctx do
      project = insert!(:project)
      insert!(:project_member, project: project, user: ctx.user, role: "regular")

      ctx.conn
      |> put("/api/v1/projects/#{project.id}", project: %{name: "New name"})
      |> json_response(403)
    end

    test "fail to update missing project", ctx do
      ctx.conn
      |> put("/api/v1/projects/9999999999", project: %{name: "New name"})
      |> json_response(404)
    end
  end

  describe "DELETE /api/v1/projects/:id" do
    test "delete project as project admin", ctx do
      project = insert!(:project)
      insert!(:project_member, project: project, user: ctx.user, role: "admin")
      ctx.conn |> delete("/api/v1/projects/#{project.id}") |> json_response(200)
      ctx.conn |> get("/api/v1/projects/#{project.id}") |> json_response(404)
    end

    test "delete project as global admin", ctx do
      admin = insert!(:admin)
      conn = ctx.conn |> sign_as(admin)

      project = insert!(:project)
      conn |> delete("/api/v1/projects/#{project.id}") |> json_response(200)
      conn |> get("/api/v1/projects/#{project.id}") |> json_response(404)
    end

    test "fail to delete someone's inbox project even as global admin", ctx do
      admin = insert!(:admin)
      conn = ctx.conn |> sign_as(admin)

      project = insert!(:project)
      insert!(:user, inbox_project: project)
      conn |> delete("/api/v1/projects/#{project.id}") |> json_response(403)
    end

    test "fail to delete project without admin access", ctx do
      project = insert!(:project)
      ctx.conn |> delete("/api/v1/projects/#{project.id}") |> json_response(403)
    end

    test "fail to delete missing project", ctx do
      ctx.conn |> delete("/api/v1/projects/9999999999") |> json_response(404)
    end
  end
end
