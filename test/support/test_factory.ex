defmodule SiresTaskApi.TestFactory do
  alias SiresTaskApi.Repo

  def build(:user) do
    %SiresTaskApi.User{
      email: "user#{sequence()}@example.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt("12345"),
      inbox_project: build(:project, name: "Inbox")
    }
  end

  def build(:admin) do
    build(:user, role: "admin")
  end

  def build(:project) do
    %SiresTaskApi.Project{
      name: "Project ##{sequence()}"
    }
  end

  def build(:project_member) do
    %SiresTaskApi.Project.Member{
      project: build(:project),
      user: build(:user),
      role: "regular"
    }
  end

  def build(:task) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %SiresTaskApi.Task{
      project: build(:project),
      name: "Task #{sequence()}",
      description: "Do something",
      start_time: now,
      finish_time: now |> DateTime.add(24 * 60 * 60),
      creator: build(:user),
      editor: build(:user)
    }
  end

  def build(:task_member) do
    %SiresTaskApi.Task.Member{
      task: build(:task),
      user: build(:user),
      role: "responsible"
    }
  end

  def build(factory_name, attrs) do
    factory_name |> build() |> struct(attrs)
  end

  def insert!(factory_name, attrs \\ []) do
    Repo.insert!(build(factory_name, attrs))
  end

  def sequence, do: System.unique_integer([:positive, :monotonic])
end
