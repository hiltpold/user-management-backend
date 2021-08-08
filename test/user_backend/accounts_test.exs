defmodule UserBackend.AccountsTest do
  use UserBackend.DataCase
  alias UserBackend.Accounts
  alias UserBackend.Accounts.Notification
  alias UserBackend.Accounts.User
  use ExUnit.Case
  require Logger
  use Bamboo.Test

  describe "users" do
    alias UserBackend.Accounts.User
    @valid_attrs %{email: "some@mail.com", password: "Password#1", role: "user"}
    @update_attrs %{
      email: "some_other@mail.com",
      password: "Password#2"
    }
    @invalid_attrs %{email: nil, password: nil, role: nil, }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()
      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [%{user | password: nil}]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == %{user | password: nil}
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some@mail.com"
      assert user.is_verified == false
      assert user.role == "user"
      assert Bcrypt.verify_pass("Password#1", user.password_hash)
   end

   test "create_user/1 with invalid data returns error changeset" do
     assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
   end

  test "update_user/2 with valid data updates the user" do
    user = user_fixture()
    assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
    assert {:ok, %User{} = user} = Accounts.update_user_password(user.email, @update_attrs)
    assert user.email == "some_other@mail.com"
    assert user.is_verified  == false
    assert Bcrypt.verify_pass("Password#2", user.password_hash)
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = user_fixture()
    test =Accounts.update_user(user, @invalid_attrs)
    Logger.info(">>>>>>>>>#{inspect(test)}")
    assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    assert %{user | password: nil} == Accounts.get_user!(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = user_fixture()
    assert {:ok, %User{}} = Accounts.delete_user(user)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
  end

  test "change_user/1 returns a user changeset" do
    user = user_fixture()
    assert %Ecto.Changeset{} = Accounts.change_user(user)
  end

   test "deliver_confirmation_instructions/2 delivers account confirmation mail" do
      user = user_fixture()
      {:ok, email} = Notification.deliver_confirmation_instructions(user, "some url")
      assert_delivered_email(email)
   end

   test "deliver_password_reset_confirmation/2 delivers new password mail" do
      user = user_fixture()
      {:ok, email} = Notification.deliver_password_reset_confirmation(user.email , "some new password")
      assert_delivered_email(email)
   end

  end
end
