defmodule SiresTaskApiWeb.CurrentUserEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  describe "GET /api/v1/current_user" do
    setup do
      user = insert!(:user, email: "some@email.com", password: "some password")
      {:ok, user: user}
    end

    test "renders user", ctx do
      response =
        ctx.conn
        |> sign_as(ctx.user)
        |> get("/api/v1/current_user")
        |> json_response(200)

      assert %{"user" => %{"id" => _, "email" => "some@email.com"}} = response
    end

    test "returns 401 on wrong JWT", ctx do
      ctx.conn
      |> put_req_header("authorization", "Bearer wrong")
      |> get("/api/v1/current_user")
      |> json_response(401)
    end

    test "returns 401 on missing JWT", ctx do
      ctx.conn
      |> get("/api/v1/current_user")
      |> json_response(401)
    end
  end
end
