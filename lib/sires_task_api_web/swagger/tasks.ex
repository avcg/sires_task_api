defmodule SiresTaskApiWeb.Swagger.Tasks do
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Task:
        swagger_schema do
          title("Task")

          properties do
            project_id(:integer, "Project id", required: true)
            name(:string, "Name", required: true)
            description(:string, "Description")
            start_time(:string, "UTC start time")
            finish_time(:string, "UTC finish time")
          end
        end
    }
  end

  swagger_path :create do
    post("/tasks")
    tag("Tasks")
    summary("Create a task")

    parameters do
      body(
        :body,
        Schema.new do
          properties do
            project(Schema.ref(:Task), "Task properties", required: true)
          end
        end,
        "Body",
        required: true
      )
    end

    response(201, "Created")
    response(400, "Bad Request")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(422, "Unprocessable Entity")
  end
end
