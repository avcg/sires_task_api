defmodule SiresTaskApi.User.SharedHelpers do
  import Ecto.Changeset

  def changeset(user, attrs, opts \\ []) do
    fields = [:email, :password]
    fields = if opts[:admin], do: fields ++ [:role], else: fields

    user
    |> cast(attrs, fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_inclusion(:role, ~w(regular admin))
    |> unique_constraint(:email, name: :users_lower_email_index)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
