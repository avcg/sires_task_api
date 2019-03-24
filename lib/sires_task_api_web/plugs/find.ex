defmodule SiresTaskApiWeb.Find do
  import Plug.Conn
  alias SiresTaskApi.Repo

  def init(opts) do
    [
      schema: opts[:schema] || raise("Required `schema` option not specified"),
      key: opts[:assign] || raise("Required `assign` option not specified"),
      path: opts[:path] || [to_string(opts[:param] || "id")],
      field: opts[:field] || :id,
      preload: opts[:preload] || [],
      policy: opts[:policy],
      auth_action: opts[:auth_action],
      optional: opts[:optional],
      skip_missing: opts[:skip_missing],
      skip_authorization: opts[:skip_authorization]
    ]
  end

  def call(conn, opts) do
    with {:ok, pk} <- fetch_pk(conn, opts),
         {:ok, struct} <- find_struct(pk, opts),
         :ok <- (opts[:skip_authorization] && :ok) || authorize_struct(conn, struct, opts) do
      conn |> assign(opts[:key], struct)
    else
      error -> conn |> SiresTaskApiWeb.FallbackController.call(error) |> halt()
    end
  end

  defp fetch_pk(conn, opts) do
    case conn.params |> get_in(opts[:path]) do
      nil -> (opts[:optional] && {:ok, nil}) || {:error, :missing_param}
      pk -> {:ok, pk}
    end
  end

  defp find_struct(nil, _), do: {:ok, nil}

  defp find_struct(pk, opts) do
    opts[:schema]
    |> Repo.get_by([{opts[:field], pk}])
    |> Repo.preload(opts[:preload])
    |> case do
      nil -> (opts[:skip_missing] && {:ok, nil}) || {:error, :not_found}
      struct -> {:ok, struct}
    end
  end

  defp authorize_struct(_, nil, _), do: :ok

  defp authorize_struct(conn, struct, opts) do
    mod = opts[:policy] || raise("Required `policy` option not specified")
    action = opts[:auth_action] || conn |> Phoenix.Controller.action_name()
    user = conn.assigns.current_user
    Bodyguard.permit(mod, action, user, struct)
  end
end
