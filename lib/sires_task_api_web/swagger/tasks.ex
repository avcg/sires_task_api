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

  swagger_path :show do
    get("/tasks/{id}")
    tag("Tasks")
    summary("Show task")

    parameters do
      id(:path, :string, "Task id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
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

  swagger_path :update do
    put("/tasks/{id}")
    tag("Tasks")
    summary("Update a task")
    description("Available only for task assignors, project admins and global admins.")

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

    response(200, "OK")
    response(400, "Bad Request")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
    response(422, "Unprocessable Entity")
  end

  swagger_path :delete do
    delete("/tasks/{id}")
    tag("Tasks")
    summary("Delete task")
    description("Available only for task assignors, project admins and global admins.")

    parameters do
      id(:path, :string, "Task id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end
end
