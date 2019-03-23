defmodule SiresTaskApiWeb.Swagger.CurrentUser do
  use PhoenixSwagger

  swagger_path :current_user do
    get("/current_user")
    tag("Users")
    summary("Show current user")

    response(200, "OK")
  end
end
