defmodule SiresTaskApiWeb.CurrentUserEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true
  alias SiresTaskApiWeb.Endpoint

  @token_age 60 * 60 * 24 * 30

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

      assert %{"user" => %{"id" => _, "email" => "some@email.com"}, "ws_token" => token} =
               response

      assert {:ok, user_id} = Phoenix.Token.verify(Endpoint, "user", token, max_age: @token_age)
      assert user_id == ctx.user.id
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
