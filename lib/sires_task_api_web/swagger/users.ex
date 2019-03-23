defmodule SiresTaskApiWeb.Swagger.Users do
  use PhoenixSwagger

  def swagger_definitions do
    %{
      User:
        swagger_schema do
          title("User")

          properties do
            email(:string, "Email", required: true)
            password(:string, "Password", required: true)
          end
        end
    }
  end

  swagger_path :create do
    post("/users")
    tag("Users")
    summary("Create a user")

    parameters do
      body(
        :body,
        Schema.new do
          properties do
            user(Schema.ref(:User), "User properties", required: true)
          end
        end,
        "Body",
        required: true
      )
    end

    response(201, "Created")
    response(401, "Unauthorized")
  end
end
