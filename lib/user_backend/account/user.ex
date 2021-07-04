defmodule UserBackend.Account.User do
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
    field :role, :string, default: ""
    field :is_verified, :boolean, default: false
    # Add support for microseconds at the language level
    # for this specific schema
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :is_verified, :password, :role])
    |> validate_required([:email, :is_verified, :password])
    |> validate_format(:email, ~r/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    |> unique_constraint(:email)
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

  def update_user_changeset(user, attrs) do
    user
      |> cast(attrs, [:email, :is_verified, :password, :role])
      |> validate_required([:email, :is_verified, :password, :role])
      |> unique_constraint(:email)
  end
end
