defmodule Mix.Tasks.Swagger do
  use Mix.Task

  @shortdoc "Generates swagger.json file"

  @initial_document %{
    swagger: "2.0",
    info: %{title: "Sires Task API", version: "1.0"},
    basePath: "/api/v1",
    consumes: ~w(application/json),
    produces: ~w(application/json),
    security: [%{api_key: []}],
    securityDefinitions: %{api_key: %{type: "apiKey", name: "Authorization", in: "header"}}
  }

  def run(_args) do
    Mix.Task.run("compile")
    Mix.Task.reenable("swagger")
    Code.append_path("#{app_path()}_build/#{Mix.env()}/lib/#{app_name()}/ebin")
    "priv/static/swagger.json" |> File.write!(swagger_document())
  end

  defp app_path do
    Mix.Project.compile_path()
    |> String.split("_build")
    |> Enum.at(0)
  end

  defp app_name, do: Mix.Project.get().project()[:app]

  defp swagger_document do
    modules = swagger_modules()

    @initial_document
    |> Map.put_new(:paths, collect_paths(modules))
    |> Map.put_new(:definitions, collect_definitions(modules))
    |> Jason.encode!(pretty: true)
  end

  defp swagger_modules do
    for {module, _} <- :code.all_loaded(),
        to_string(module) =~ ~r/^Elixir\.SiresTaskApiWeb\.Swagger\./,
        do: module
  end

  defp collect_paths(modules) do
    paths =
      for module <- modules,
          {fun, _} <- module.__info__(:functions),
          to_string(fun) =~ ~r/^swagger_path_/,
          do: module |> apply(fun, [nil]) |> Map.to_list() |> List.first()

    Enum.reduce(paths, %{}, fn {path, methods}, acc ->
      combined_methods = acc |> Map.get(path, %{}) |> Map.merge(methods)
      acc |> Map.put(path, combined_methods)
    end)
  end

  defp collect_definitions(modules) do
    Enum.reduce(modules, %{}, fn module, acc ->
      if module |> :erlang.function_exported(:swagger_definitions, 0) do
        acc |> Map.merge(apply(module, :swagger_definitions, []))
      else
        acc
      end
    end)
  end
end
