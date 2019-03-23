defmodule SiresTaskApiWeb.Guardian do
  use Guardian, otp_app: :sires_task_api
  alias SiresTaskApi.{Repo, User}

  def subject_for_token(%User{id: id}, _claims), do: {:ok, to_string(id)}

  def resource_from_claims(%{"sub" => id}) do
    case User |> Repo.get(id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :user_not_found}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end
end
