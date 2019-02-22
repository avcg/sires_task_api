defmodule SiresTaskApiWeb.UserEndpointTest do
  use SiresTaskApiWeb.ConnCase

  @create_attrs %{
    email: "some@email.com",
    password: "some password"
  }

  @invalid_attrs %{email: nil, password: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      response = json_response(conn, 201)["user"]
      assert %{"id" => _, "email" => "some@email.com"} = response
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
