defmodule SiresTaskApi.User.SharedHelpers do
  import Ecto.Changeset
  import Arc.Ecto.Schema

  def validate_params(changeset) do
    Ecto.Changeset.validate_change(
      changeset,
      :user,
      fn :user, changeset  ->
        changeset
        |> Ecto.Changeset.validate_inclusion(:locale, Gettext.known_locales(SiresTaskApi.Gettext))
        |> Map.fetch!(:errors)
      end
    )
  end

  def changeset(user, attrs, opts \\ []) do
    fields = ~w(email password first_name middle_name last_name position locale)a
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
    |> validate_inclusion(:locale, Gettext.known_locales(SiresTaskApi.Gettext))
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
