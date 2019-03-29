defmodule SiresTaskApiWeb.Swagger.Tasks do
  use PhoenixSwagger

  @task_member_roles ~w(assignor responsible co-responsible observer)
  @reference_types ~w(subtask blocker)

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

            tag_ids(
              :array,
              "Tag ids. Replaces the whole set when specified on update.",
              items: :integer
            )

            attachments(
              :array,
              "Attachments",
              items: Schema.ref(:TaskAttachment)
            )
          end
        end,
      Member:
        swagger_schema do
          title("Task member")

          properties do
            user_id(:integer, "User id", required: true)
            role(:string, "Role", enum: @task_member_roles, required: true)
          end
        end,
      Reference:
        swagger_schema do
          title("Task reference")

          properties do
            task_id(:integer, "Child task id", required: true)
            reference_type(:string, "Reference type", enum: @reference_types, required: true)
          end
        end,
      TaskAttachment:
        swagger_schema do
          title("Task attachment")

          properties do
            file(:file, "File")
          end
        end,
      Comment:
        swagger_schema do
          title("Task comment")

          properties do
            text(:string, "Text", required: true)

            attachments(
              :array,
              "Attachments",
              items: Schema.ref(:CommentAttachment)
            )
          end
        end,
      CommentAttachment:
        swagger_schema do
          title("Comment attachment")

          properties do
            file(:file, "File")
          end
        end
    }
  end

  swagger_path :index do
    get("/tasks")
    tag("Tasks")
    summary("List tasks")
    paging(size: "limit", offset: "offset")

    parameters do
      search(:query, :string, "Search string")
      project_id(:query, :integer, "Filter by project id")
      done(:query, :boolean, "Filter by done flag")
      finish_date(:query, :string, "Filter by finish date. Format: yyyy-mm-dd.")
      hot(:query, :boolean, "Filter tasks with finish time in the last 7 days")
      role(:query, :string, "Filter by current user's role in the task", enum: @task_member_roles)
      tags(:query, :array, "Filter by tags", items: :string)
    end

    response(200, "OK")
  end

  swagger_path :calendar do
    get("/tasks/calendar")
    tag("Tasks")
    summary("Calendar for specified month")
    paging(size: "limit", offset: "offset")

    parameters do
      year(:query, :integer, "Year", required: true, minimum: 2000, maximum: 9999)
      month(:query, :integer, "Month", required: true, minimum: 1, maximum: 12)
    end

    response(200, "OK")
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
      role(:query, :string, "Role", required: true, enum: @task_member_roles)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
    response(422, "Unprocessable Entity")
  end

  swagger_path :add_reference do
    post("/tasks/{task_id}/references")
    tag("Tasks")
    summary("Reference a task to another task")
    description("Available only for task assignors, project admins and global admins.")

    parameters do
      task_id(:path, :integer, "Parent task id", required: true)

      body(
        :body,
        Schema.new do
          properties do
            member(Schema.ref(:Reference), "Reference properties", required: true)
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

  swagger_path :remove_reference do
    delete("/tasks/{task_id}/references/{id}")
    tag("Tasks")
    summary("Remove references to a task from another task")
    description("Available only for task assignors, project admins and global admins.")

    parameters do
      task_id(:path, :integer, "Parent task id", required: true)
      id(:path, :integer, "Child task id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
    response(422, "Unprocessable Entity")
  end

  swagger_path :add_comment do
    post("/tasks/{task_id}/comments")
    tag("Tasks")
    summary("Add comment to task")
    description("Available only for project members and global admins.")

    parameters do
      task_id(:path, :integer, "Task id", required: true)

      body(
        :body,
        Schema.new do
          properties do
            member(Schema.ref(:Comment), "Comment properties", required: true)
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

  swagger_path :change_comment do
    put("/tasks/{task_id}/comments/{id}")
    tag("Tasks")
    summary("Change comment")
    description("Available only for comment author, project admins and global admins.")

    parameters do
      task_id(:path, :integer, "Task id", required: true)
      id(:path, :integer, "Comment id", required: true)

      body(
        :body,
        Schema.new do
          properties do
            member(Schema.ref(:Comment), "Comment properties", required: true)
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

  swagger_path :remove_comment do
    delete("/tasks/{task_id}/commetns/{id}")
    tag("Tasks")
    summary("Remove comment from task")
    description("Available only for comment author, project admins and global admins.")

    parameters do
      task_id(:path, :integer, "Task id", required: true)
      id(:path, :integer, "Comment id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end

  swagger_path :index_attachment_versions do
    get("/tasks/{task_id}/attachments/{attachment_id}/versions")
    tag("Tasks")
    summary("List attachment versions")
    description("Available only for project members and global admins.")

    parameters do
      task_id(:path, :integer, "Task id", required: true)
      attachment_id(:path, :integer, "Attachment id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end

  swagger_path :add_attachment_versions do
    post("/tasks/{task_id}/attachments/{attachment_id}/versions")
    tag("Tasks")
    summary("Add task attachment version")
    description("Available only for task assignors, project admins and global admins.")

    parameters do
      task_id(:path, :integer, "Task id", required: true)
      attachment_id(:path, :integer, "Attachment id", required: true)

      body(
        :body,
        Schema.new do
          properties do
            member(Schema.ref(:TaskAttachment), "Attachment properties", required: true)
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
end
