defmodule UserBackend.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :password_hash, :string
      add :is_verified, :boolean, default: false, null: false
      add :role, :string, default: nil, null: true

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
