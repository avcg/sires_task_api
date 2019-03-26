defmodule SiresTaskApiWeb.ErrorView do
  use SiresTaskApiWeb, :view

  def render("422", %{reason: reason}) do
    %{errors: %{detail: reason}}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
