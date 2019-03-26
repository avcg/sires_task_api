defmodule SiresTaskApiWeb.Swagger.Tags do
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Tag:
        swagger_schema do
          title("Tag")

          properties do
            name(:string, "Name", required: true)
          end
        end
    }
  end

  swagger_path :index do
    get("/tags")
    tag("Tags")
    summary("List tags")
    paging(size: "limit", offset: "offset")

    response(200, "OK")
  end

  swagger_path :create do
    post("/tags")
    tag("Tags")
    summary("Create a tag")
    description("Available only for admins.")

    parameters do
      body(
        :body,
        Schema.new do
          properties do
            project(Schema.ref(:Tag), "Tag properties", required: true)
          end
        end,
        "Body",
        required: true
      )
    end

    response(201, "Created")
    response(400, "Bad Request")
    response(401, "Unauthorized")
    response(422, "Unprocessable Entity")
  end

  swagger_path :update do
    put("/tags/{id}")
    tag("Tags")
    summary("Update a tag")
    description("Available only for admins.")

    parameters do
      id(:path, :integer, "Tag id", required: true)

      body(
        :body,
        Schema.new do
          properties do
            project(Schema.ref(:Tag), "Tag properties", required: true)
          end
        end,
        "Body",
        required: true
      )
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
    response(422, "Unprocessable Entity")
  end

  swagger_path :delete do
    delete("/tags/{id}")
    tag("Tags")
    summary("Delete tag")
    description("Available only for admins.")

    parameters do
      id(:path, :string, "Tag id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end
end
