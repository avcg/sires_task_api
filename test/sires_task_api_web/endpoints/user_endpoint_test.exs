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

  describe "POST /api/v1/users/:id/(de)activate" do
    test "toggle user active off and on", ctx do
      user = insert!(:user)
      admin = insert!(:admin)

      # Deactivate user as admin
      response =
        ctx.conn
        |> sign_as(admin)
        |> post("/api/v1/users/#{user.id}/deactivate")
        |> json_response(200)

      assert response["user"]["active"] == false

      # Fail to use existing JWT as user
      ctx.conn
      |> sign_as(user)
      |> get("/api/v1/current_user")
      |> json_response(401)

      # Fail to sign in as deactivated user
      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/sign_in", email: user.email, password: "12345")
      |> json_response(401)

      # Activate user as admin
      response =
        ctx.conn
        |> sign_as(admin)
        |> post("/api/v1/users/#{user.id}/activate")
        |> json_response(200)

      assert response["user"]["active"] == true

      # Use existing JWT as active user
      ctx.conn
      |> sign_as(user)
      |> get("/api/v1/current_user")
      |> json_response(200)

      # Sign in as active user
      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/sign_in", email: user.email, password: "12345")
      |> json_response(201)
    end

    test "fail to deactivate someone as a regular user", ctx do
      user = insert!(:user)
      other_user = insert!(:user)

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/users/#{other_user.id}/deactivate")
      |> json_response(403)
    end
  end
end
