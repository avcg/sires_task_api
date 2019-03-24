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
            role(:string, "Role (only admins can change it)", enum: ~w(regular admin))
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

  swagger_path :update do
    put("/users/{id}")
    tag("Users")
    summary("Update a user")

    parameters do
      id(:path, :integer, "User id", required: true)

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

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end

  swagger_path :deactivate do
    post("/users/{id}/deactivate")
    tag("Users")
    summary("Deactivate a user")
    description("Only available for admins. Deactivated user can't sign in or use existing JWT.")

    parameters do
      id(:path, :integer, "User id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end

  swagger_path :activate do
    post("/users/{id}/activate")
    tag("Users")
    summary("Activate a user")
    description("Put back previously deactivated user.")

    parameters do
      id(:path, :integer, "User id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end
end
