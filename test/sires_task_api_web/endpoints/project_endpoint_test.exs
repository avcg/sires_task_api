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
end
