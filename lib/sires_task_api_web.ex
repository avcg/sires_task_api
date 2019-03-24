defmodule SiresTaskApiWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use SiresTaskApiWeb, :controller
      use SiresTaskApiWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: SiresTaskApiWeb

      import Plug.Conn
      import SiresTaskApiWeb.Gettext
      alias SiresTaskApiWeb.Router.Helpers, as: Routes
      alias SiresTaskApiWeb.Controller.Helpers.Pagination

      action_fallback SiresTaskApiWeb.FallbackController

      def run(operation, conn, params) do
        context = %{user: conn.assigns[:current_user]}
        operation |> ExOperation.run(context, params)
      end
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/sires_task_api_web/templates",
        namespace: SiresTaskApiWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      import SiresTaskApiWeb.ErrorHelpers
      import SiresTaskApiWeb.Gettext
      alias SiresTaskApiWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import SiresTaskApiWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
