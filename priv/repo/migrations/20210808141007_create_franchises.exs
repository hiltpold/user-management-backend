defmodule UserBackend.Repo.Migrations.CreateFranchises do
  use Ecto.Migration

  def change do
    create table(:franchises, primary_key: false) do
      add :id, :binary_id, primary_key: true

      timestamps()
    end

  end
end
