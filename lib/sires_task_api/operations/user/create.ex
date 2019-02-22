defmodule SiresTaskApi.User.Create do
  use SiresTaskApi.Operation, params: %{user!: %{email!: :string, password!: :string}}
  import Ecto.Changeset
  alias SiresTaskApi.{Repo, User}

  def call(op) do
    op
    |> step(:create_user, fn _ -> create_user(op.params.user) end)
  end

  defp create_user(params) do
    %User{}
    |> changeset(params)
    |> Repo.insert()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email) #todo: need to add lowcase to email
    |> put_password_hash
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}}
        ->
          put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
          changeset
    end
  end
end
