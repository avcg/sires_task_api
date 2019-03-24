defmodule SiresTaskApiWeb.SignInEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  describe "POST /api/v1/sign_in" do
    test "renders user when data is valid", ctx do
      user =
        insert!(:user,
          email: "some@email.com",
          password_hash: Comeonin.Bcrypt.hashpwsalt("some password")
        )

      response =
        ctx.conn
        |> post("/api/v1/sign_in", email: "Some@Email.com", password: "some password")
        |> json_response(200)

      assert %{"user" => %{"id" => _, "email" => "some@email.com"}, "jwt" => token} = response

      # Try to use the obtained JWT
      response =
        ctx.conn
        |> sign_as(user)
        |> get(Routes.current_user_path(ctx.conn, :show))
        |> json_response(200)

      assert %{"user" => %{"id" => _, "email" => "some@email.com"}} = response
    end

    test "renders error when password is wrong", ctx do
      user = insert!(:user)

      ctx.conn
      |> post("/api/v1/sign_in", email: user.email, password: "wrong password")
      |> json_response(401)
    end

    test "renders error when a user with the given email is missing", ctx do
      ctx.conn
      |> post("/api/v1/sign_in", email: "missing@user.com", password: "missing")
      |> json_response(401)
    end

    test "renders error when email and password are missing", ctx do
      ctx.conn
      |> post("/api/v1/sign_in")
      |> json_response(401)
    end
  end
end
