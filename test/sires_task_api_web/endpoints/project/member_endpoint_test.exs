defmodule SiresTaskApiWeb.Project.MemberEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  describe "POST /api/v1/projects/:project_id/members" do
    test "add member to project as project admin", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      project = insert!(:project)
      insert!(:project_member, project: project, user: user, role: "admin")
      params = %{user_id: other_user.id, role: "guest"}

      response =
        ctx.conn
        |> sign_as(user)
        |> post("/api/v1/projects/#{project.id}/members", member: params)
        |> json_response(201)

      assert response["member"]["role"] == "guest"
      assert response["member"]["user"]["id"] == other_user.id
    end

    test "add member to project as global admin", ctx do
      admin = insert!(:admin)
      other_user = insert!(:user)
      project = insert!(:project)

      response =
        ctx.conn
        |> sign_as(admin)
        |> post("/api/v1/projects/#{project.id}/members", member: %{user_id: other_user.id})
        |> json_response(201)

      assert response["member"]["role"] == "regular"
      assert response["member"]["user"]["id"] == other_user.id
    end

    test "fail to add member without admin permissions", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      project = insert!(:project)
      insert!(:project_member, project: project, user: user, role: "regular")

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/projects/#{project.id}/members", member: %{user_id: other_user.id})
      |> json_response(403)
    end

    test "fail to add member twice", ctx do
      user = insert!(:user)
      other_user = insert!(:user)
      project = insert!(:project)
      insert!(:project_member, project: project, user: user, role: "admin")
      insert!(:project_member, project: project, user: other_user)

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/projects/#{project.id}/members", member: %{user_id: other_user.id})
      |> json_response(422)
    end

    test "fail to add non-existing user as member", ctx do
      user = insert!(:user)
      project = insert!(:project)
      insert!(:project_member, project: project, user: user, role: "admin")

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/projects/#{project.id}/members", member: %{user_id: 9_999_999_999})
      |> json_response(404)
    end

    test "fail to add member to a non-existing project", ctx do
      user = insert!(:user)
      other_user = insert!(:user)

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/projects/9999999999/members", member: %{user_id: other_user.id})
      |> json_response(404)
    end
  end
end
