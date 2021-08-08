defmodule UserBackend.Leagues do
  @moduledoc """
  The Leagues context.
  """

  import Ecto.Query, warn: false
  alias UserBackend.Repo

  alias UserBackend.Leagues.Franchise

  @doc """
  Returns the list of franchises.

  ## Examples

      iex> list_franchises()
      [%Franchise{}, ...]

  """
  def list_franchises do
    Repo.all(Franchise)
  end

  @doc """
  Gets a single franchise.

  Raises `Ecto.NoResultsError` if the Franchise does not exist.

  ## Examples

      iex> get_franchise!(123)
      %Franchise{}

      iex> get_franchise!(456)
      ** (Ecto.NoResultsError)

  """
  def get_franchise!(id), do: Repo.get!(Franchise, id)

  @doc """
  Creates a franchise.

  ## Examples

      iex> create_franchise(%{field: value})
      {:ok, %Franchise{}}

      iex> create_franchise(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_franchise(attrs \\ %{}) do
    %Franchise{}
    |> Franchise.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a franchise.

  ## Examples

      iex> update_franchise(franchise, %{field: new_value})
      {:ok, %Franchise{}}

      iex> update_franchise(franchise, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_franchise(%Franchise{} = franchise, attrs) do
    franchise
    |> Franchise.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a franchise.

  ## Examples

      iex> delete_franchise(franchise)
      {:ok, %Franchise{}}

      iex> delete_franchise(franchise)
      {:error, %Ecto.Changeset{}}

  """
  def delete_franchise(%Franchise{} = franchise) do
    Repo.delete(franchise)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking franchise changes.

  ## Examples

      iex> change_franchise(franchise)
      %Ecto.Changeset{data: %Franchise{}}

  """
  def change_franchise(%Franchise{} = franchise, attrs \\ %{}) do
    Franchise.changeset(franchise, attrs)
  end
end
