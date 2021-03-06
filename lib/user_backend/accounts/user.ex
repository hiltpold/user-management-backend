defmodule UserBackend.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger

  @roles ~w(user admin)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :role, :string, default: "user"
    field :is_verified, :boolean, default: false
    # Add support for microseconds at the language level
    # for this specific schema
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :role, :is_verified])
    |> validate_email()
    |> validate_password()
    |> validate_required([:is_verified, :password])
    |> put_password_hash()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:email, max: 80)
    |> unsafe_validate_unique(:email, UserBackend.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/[0-9]+/, message: "Password must contain a number")
    |> validate_format(:password, ~r/[A-Z]+/, message: "Password must contain an upper-case letter")
    |> validate_format(:password, ~r/[a-z]+/, message: "Password must contain a lower-case letter")
    |> validate_format(:password, ~r/[#\!\?&@\$%^&*\(\)]+/, message: "Password must contain a symbol")
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_password_hash(changeset) do
    changeset
  end

  def update_password_hash_changeset(user, attrs) do
    user
      |> cast(attrs, [:password])
      |> validate_required([:password])
      |> put_password_hash()
  end

  def change_verified_changeset(user, attrs) do
    user
      |> cast(attrs, [:is_verified])
      |> validate_required([:is_verified])
  end

  def update_user_changeset(user, attrs) do
    user
      |> cast(attrs, [:email, :password, :password_hash, :is_verified, :role])
      |> validate_required([:email, :password_hash, :is_verified, :role])
      |> unique_constraint(:email)
  end
end
