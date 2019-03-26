defmodule SiresTaskApiWeb.TagEndpointTest do
  use SiresTaskApiWeb.ConnCase, async: true

  setup %{conn: conn} do
    admin = insert!(:admin)
    {:ok, conn: conn |> sign_as(admin), admin: admin}
  end

  describe "GET /api/v1/tags" do
    test "list tags", ctx do
      [tag1, tag2, tag3] = for _ <- 1..3, do: insert!(:tag)

      response = ctx.conn |> get("/api/v1/tags") |> json_response(200)
      ids = response["tags"] |> Enum.map(& &1["id"])

      assert tag1.id in ids
      assert tag2.id in ids
      assert tag3.id in ids

      assert response["total_count"] == 3
    end
  end

  describe "POST /api/v1/tags" do
    test "create tag", ctx do
      response =
        ctx.conn
        |> post("/api/v1/tags", tag: %{name: "Hello"})
        |> json_response(201)

      assert response["tag"]["creator"]["id"] == ctx.admin.id
      assert response["tag"]["editor"]["id"] == ctx.admin.id
    end

    test "fail to create tag as regular user", ctx do
      user = insert!(:user)

      ctx.conn
      |> sign_as(user)
      |> post("/api/v1/tags", tag: %{name: "Hello"})
      |> json_response(403)
    end

    test "fail to create tag with wrong params", ctx do
      ctx.conn
      |> post("/api/v1/tags", tag: %{})
      |> json_response(422)
    end
  end

  describe "PUT /api/v1/tags/:id" do
    setup do
      {:ok, tag: insert!(:tag)}
    end

    test "update tag", ctx do
      response =
        ctx.conn
        |> put("/api/v1/tags/#{ctx.tag.id}", tag: %{name: "New name"})
        |> json_response(200)

      assert response["tag"]["name"] == "New name"
      assert response["tag"]["editor"]["id"] == ctx.admin.id
    end

    test "fail to update tag with wrong params", ctx do
      ctx.conn
      |> put("/api/v1/tags/#{ctx.tag.id}", tag: %{})
      |> json_response(422)
    end

    test "fail to update tag without admin access", ctx do
      user = insert!(:user)

      ctx.conn
      |> sign_as(user)
      |> put("/api/v1/tags/#{ctx.tag.id}", tag: %{name: "New name"})
      |> json_response(403)
    end

    test "fail to update missing tag", ctx do
      ctx.conn
      |> put("/api/v1/tags/9999999999", tag: %{name: "New name"})
      |> json_response(404)
    end
  end

  describe "DELETE /api/v1/tags/:id" do
    setup do
      {:ok, tag: insert!(:tag)}
    end

    test "delete tag", ctx do
      ctx.conn |> delete("/api/v1/tags/#{ctx.tag.id}") |> json_response(200)
      response = ctx.conn |> get("/api/v1/tags") |> json_response(200)
      ids = response |> get_in(["tags", Access.all(), "id"])
      refute ctx.tag.id in ids
    end

    test "fail to delete tag without admin access", ctx do
      user = insert!(:user)
      ctx.conn |> sign_as(user) |> delete("/api/v1/tags/#{ctx.tag.id}") |> json_response(403)
    end

    test "fail to delete missing tag", ctx do
      ctx.conn |> delete("/api/v1/tags/9999999999") |> json_response(404)
    end
  end
end
