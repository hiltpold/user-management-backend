defmodule UserBackend.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias UserBackend.Repo
  alias UserBackend.Misc.Utils
  alias UserBackend.Accounts.User
  require Logger
  import Ecto.Changeset
  alias UserBackend.Accounts

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_by!(id) do
    case Repo.get_by(User, id: id) do
      nil ->
        {:error, "No user with this id exisits"}
      user ->
        {:ok, user}
    end
  end

  def get_by_email!(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, "No user with this email exisits"}
      user ->
        {:ok, user}
    end
  end

  def get_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, "No user with this email exisits"}
      user ->
        {:ok, user}
    end
  end
  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    Logger.debug inspect attrs
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
      |> User.update_user_changeset(attrs)
      |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  TODO
  """
  def update_user_password(email, new_password) do
    with {:ok, %User{} = user} <- get_user_by_email(email) do
      changes = User.update_password_hash_changeset(user, new_password)
      Repo.update(changes)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def token_sign_in(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        UserBackend.Guardian.encode_and_sign(user)
      _ ->
        {:error, :unauthorized}
    end
  end

  def email_password_auth(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_user_by_email(email),
    do: verify_password(password, user)
  end

  defp get_user_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        verify_password()
        {:error, "Wrong email or password"}
      user ->
        {:ok, user}
    end
  end

  defp verify_password() do
    # Perform a dummy check to make user enumeration more difficult
    Bcrypt.no_user_verify()
    {:error, "Wrong email or password"}
  end

  defp verify_password(password, user) do
    if Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, "Wrong email or password"}
    end
  end
end
