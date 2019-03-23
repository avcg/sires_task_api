defmodule SiresTaskApiWeb.Swagger.SignIn do
  use PhoenixSwagger

  swagger_path :sign_in do
    post("/sign_in")
    tag("Authentication")
    summary("Sign in")

    description("""
    Signs the user in by email and password and returns JWT for accessing protected endpoints and the user info.
    Use the token in the Authorization header, e.g.: `Authorization: Bearer 12345abcd`
    """)

    parameters do
      body(
        :body,
        Schema.new do
          properties do
            email(:string, "Email", required: true)
            password(:string, "Password", required: true)
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
