defmodule UserBackend.Leagues.Franchise do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "franchises" do
    field :name, :string


    timestamps()
  end

  @doc false
  def changeset(franchise, attrs) do
    franchise
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
