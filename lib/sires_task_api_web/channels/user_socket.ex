defmodule SiresTaskApiWeb.UserSocket do
  use Phoenix.Socket
  alias SiresTaskApi.{Repo, User}

  channel "tasks", SiresTaskApiWeb.TaskChannel

  @token_age 60 * 60 * 24 * 30

  def connect(%{"token" => token}, socket, _connect_info) do
    with {:ok, user_id} <- Phoenix.Token.verify(socket, "user", token, max_age: @token_age),
         %User{} = user <- Repo.get(User, user_id) || {:error, :not_found} do
      {:ok, socket |> assign(:current_user, user)}
    else
      {:error, _} -> :error
    end
  end

  def id(_socket), do: nil
end
