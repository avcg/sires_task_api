defmodule SiresTaskApiWeb.Guardian.AuthPipeline do
  defmodule AuthErrorHandler do
    import Plug.Conn

    def auth_error(conn, {type, _reason}, _opts) do
      body = Jason.encode!(%{error: to_string(type)})
      send_resp(conn, 401, body)
    end
  end

  defmodule AssignCurrentUser do
    import Plug.Conn

    def init(opts), do: {:ok, opts}

    def call(conn, _opts), do: conn |> assign(:current_user, Guardian.Plug.current_resource(conn))
  end

  use Guardian.Plug.Pipeline,
    otp_app: :sires_task_api_web,
    module: SiresTaskApiWeb.Guardian,
    error_handler: AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
  plug AssignCurrentUser
end
