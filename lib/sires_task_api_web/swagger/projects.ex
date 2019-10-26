defmodule SiresTaskApiWeb.Swagger.Projects do
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Project:
        swagger_schema do
          title("Project")

          properties do
            name(:string, "Name", required: true)
            archived(:boolean, "Archived")
          end
        end,
      Member:
        swagger_schema do
          title("Project member")

          properties do
            user_id(:integer, "User id", required: true)
            role(:string, "Role", enum: ~w(admin regular guest), default: "regular")
          end
        end
    }
  end

  swagger_path :index do
    get("/projects")
    tag("Projects")
    summary("List available projects")
    paging(size: "limit", offset: "offset")

    parameters do
      archived(:query, :boolean, "Filter by archived flag")
    end

    response(200, "OK")
    response(401, "Unauthorized")
  end

  swagger_path :show do
    get("/projects/{id}")
    tag("Projects")
    summary("Show project")

    parameters do
      id(:path, :string, "Project id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end

  swagger_path :create do
    post("/projects")
    tag("Projects")
    summary("Create a project")

    parameters do
      body(
        :body,
        Schema.new do
          properties do
            project(Schema.ref(:Project), "Project properties", required: true)
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
    put("/projects/{id}")
    tag("Projects")
    summary("Update a project")
    description("Available only for project admins and global admins.")

    parameters do
      id(:path, :integer, "Project id", required: true)

      body(
        :body,
        Schema.new do
          properties do
            project(Schema.ref(:Project), "Project properties", required: true)
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
    delete("/projects/{id}")
    tag("Projects")
    summary("Delete project")

    description("""
    Available only for project admins and global admins.
    Inbox projects can't be deleted even by admins.
    """)

    parameters do
      id(:path, :string, "Project id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end

  swagger_path :add_member do
    post("/projects/{project_id}/members")
    tag("Projects")
    summary("Add member to project")
    description("Available only for project admins and global admins.")

    parameters do
      project_id(:path, :integer, "Project id", required: true)

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

  swagger_path :change_member_role do
    put("/projects/{project_id}/members/{id}")
    tag("Projects")
    summary("Change member role")
    description("Available only for project admins and global admins.")

    parameters do
      project_id(:path, :integer, "Project id", required: true)
      id(:path, :integer, "User id", required: true)

      body(
        :body,
        Schema.new do
          properties do
            member(
              Schema.new do
                properties do
                  role(:string, "Role", enum: ~w(admin regular guest), default: "regular")
                end
              end,
              "Member properties",
              required: true
            )
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

  swagger_path :remove_member do
    delete("/projects/{project_id}/members/{id}")
    tag("Projects")
    summary("Remove member from project")
    description("Available only for project admins and global admins.")

    parameters do
      project_id(:path, :integer, "Project id", required: true)
      id(:path, :integer, "User id", required: true)
    end

    response(200, "OK")
    response(401, "Unauthorized")
    response(403, "Forbidden")
    response(404, "Not Found")
  end
end
