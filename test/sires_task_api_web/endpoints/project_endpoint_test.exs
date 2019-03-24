defmodule SiresTaskApiWeb.ProjectEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  setup %{conn: conn} do
    user = insert!(:user)
    {:ok, conn: conn |> sign_as(user), user: user}
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
        |> put("/api/v1/projects/#{project.id}", project: %{name: "New name"})
        |> json_response(200)

      assert response["project"]["name"] == "New name"
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
end
