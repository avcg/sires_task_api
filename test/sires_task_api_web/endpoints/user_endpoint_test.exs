defmodule SiresTaskApiWeb.UserEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  describe "POST /api/v1/users" do
    test "renders user when data is valid", ctx do
      params = %{email: "some@email.com", password: "some password"}

      response =
        ctx.conn
        |> post("/api/v1/users", user: params)
        |> json_response(201)

      assert %{"user" => %{"id" => _, "email" => "some@email.com"}, "jwt" => _} = response
    end

    test "renders errors when data is invalid", ctx do
      response =
        ctx.conn
        |> post("/api/v1/users", user: %{email: nil, password: nil})
        |> json_response(422)

      assert response["errors"] != %{}
    end
  end
end
