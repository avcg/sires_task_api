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
        end,
      Member:
        swagger_schema do
          title("Task member")

          properties do
            user_id(:integer, "User id", required: true)

            role(:string, "Role",
              enum: ~w(assignor responsible co-responsible observer),
              required: true
            )
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

  swagger_path :mark_done do
    post("/tasks/{id}/mark_done")
    tag("Tasks")
    summary("Mark a task done")

    description("""
    Availabe only for task responsibles, co-responsibles, assignors, project admins and global admins.
    """)

    parameters do
      id(:path, :integer, "Task id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end

  swagger_path :mark_undone do
    post("/tasks/{id}/mark_undone")
    tag("Tasks")
    summary("Mark a task undone")

    description("""
    Availabe only for task responsibles, co-responsibles, assignors, project admins and global admins.
    """)

    parameters do
      id(:path, :integer, "Task id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
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

  swagger_path :add_member do
    post("/tasks/{task_id}/members")
    tag("Tasks")
    summary("Add member to task")
    description("Available only for task assignors, project admins and global admins.")

    parameters do
      task_id(:path, :integer, "Task id", required: true)

      body(
        :body,
        Schema.new do
          properties do
            member(Schema.ref(:Member), "Member properties", required: true)
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
    response(404, "Not Found")
    response(422, "Unprocessable Entity")
  end

  swagger_path :remove_member do
    delete("/tasks/{task_id}/members/{id}")
    tag("Tasks")
    summary("Remove member from task")
    description("Available only for task assignors, project admins and global admins.")

    parameters do
      task_id(:path, :integer, "Task id", required: true)
      id(:path, :integer, "User id", required: true)

      role(:query, :string, "Role",
        required: true,
        enum: ~w(assignor responsible co-responsible observer)
      )
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
    response(422, "Unprocessable Entity")
  end
end
