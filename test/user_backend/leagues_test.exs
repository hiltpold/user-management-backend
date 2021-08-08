defmodule UserBackend.LeaguesTest do
  use UserBackend.DataCase

  alias UserBackend.Leagues

  describe "franchises" do
    alias UserBackend.Leagues.Franchise

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def franchise_fixture(attrs \\ %{}) do
      {:ok, franchise} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Leagues.create_franchise()

      franchise
    end

    test "list_franchises/0 returns all franchises" do
      franchise = franchise_fixture()
      assert Leagues.list_franchises() == [franchise]
    end

    test "get_franchise!/1 returns the franchise with given id" do
      franchise = franchise_fixture()
      assert Leagues.get_franchise!(franchise.id) == franchise
    end

    test "create_franchise/1 with valid data creates a franchise" do
      assert {:ok, %Franchise{} = franchise} = Leagues.create_franchise(@valid_attrs)
    end

    test "create_franchise/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Leagues.create_franchise(@invalid_attrs)
    end

    test "update_franchise/2 with valid data updates the franchise" do
      franchise = franchise_fixture()
      assert {:ok, %Franchise{} = franchise} = Leagues.update_franchise(franchise, @update_attrs)
    end

    test "update_franchise/2 with invalid data returns error changeset" do
      franchise = franchise_fixture()
      assert {:error, %Ecto.Changeset{}} = Leagues.update_franchise(franchise, @invalid_attrs)
      assert franchise == Leagues.get_franchise!(franchise.id)
    end

    test "delete_franchise/1 deletes the franchise" do
      franchise = franchise_fixture()
      assert {:ok, %Franchise{}} = Leagues.delete_franchise(franchise)
      assert_raise Ecto.NoResultsError, fn -> Leagues.get_franchise!(franchise.id) end
    end

    test "change_franchise/1 returns a franchise changeset" do
      franchise = franchise_fixture()
      assert %Ecto.Changeset{} = Leagues.change_franchise(franchise)
    end
  end
end
