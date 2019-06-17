defmodule SiresTaskApi.User.SharedHelpers do
  import Ecto.Changeset
  import Arc.Ecto.Schema

  def changeset(user, attrs, opts \\ []) do
    fields = ~w(email password first_name middle_name last_name position)a
    fields = if opts[:admin], do: fields ++ [:role], else: fields

    user
    |> cast(attrs, fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_inclusion(:role, ~w(regular admin))
    |> validate_length(:first_name, max: 255)
    |> validate_length(:middle_name, max: 255)
    |> validate_length(:last_name, max: 255)
    |> validate_length(:position, max: 255)
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

  def upload_avatar(user, nil), do: {:ok, user}

  def upload_avatar(user, avatar) do
    user
    |> cast(%{}, [])
    |> cast_attachments(%{avatar: avatar}, [:avatar])
    |> SiresTaskApi.Repo.update()
  end
end
