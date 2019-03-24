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

  def build(factory_name, attrs) do
    factory_name |> build() |> struct(attrs)
  end

  def insert!(factory_name, attrs \\ []) do
    Repo.insert!(build(factory_name, attrs))
  end

  def sequence, do: System.unique_integer([:positive, :monotonic])
end
