defmodule SiresTaskApi.NotificationSubscriptionPolicy do
  @behaviour Bodyguard.Policy

  # TODO: Maybe not all users should be allowed to subscribe on all events.
  #       For security it's better to deny by default and add explicit clauses for each event:
  #
  #       ```
  #       def authorize(:create, _, "create_project"), do: true
  #       def authorize(:create, %User{role: "admin"}, "some_admin_event"), do: true
  #       …
  #       def authorize(:create, _, _), do: false
  #       ```
  def authorize(:create, _user, _operation), do: true
  def authorize(_, _, _), do: false
end
