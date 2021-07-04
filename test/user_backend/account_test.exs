defmodule UserBackend.AccountTest do
  use UserBackend.DataCase
  alias UserBackend.Account
  alias UserBackend.Account.Notification
  use ExUnit.Case
  require Logger
  use Bamboo.Test

  describe "users" do
    alias UserBackend.Account.User
    @valid_attrs %{email: "some@mail.com", password: "password", role: "user"}
    @update_attrs %{
      email: "updated@mail.com",
      password: "some updated password"
    }
    @invalid_attrs %{email: nil, password: nil, role: nil, }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_user()
      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Account.list_users() == [%{user | password: nil}]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Account.get_user!(user.id) == %{user | password: nil}
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Account.create_user(@valid_attrs)
      assert user.email == "some@mail.com"
      assert user.is_verified == false
      assert user.role == "user"
      assert Bcrypt.verify_pass("password", user.password_hash)
   end

   test "create_user/1 with invalid data returns error changeset" do
     assert {:error, %Ecto.Changeset{}} = Account.create_user(@invalid_attrs)
   end

  test "update_user/2 with valid data updates the user" do
    user = user_fixture()
    assert {:ok, %User{} = user} = Account.update_user(user, @update_attrs)
    assert {:ok, %User{} = user} = Account.update_user_password(user.email, @update_attrs)
    assert user.email == "updated@mail.com"
    assert user.is_verified  == false
    assert Bcrypt.verify_pass("some updated password", user.password_hash)
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = user_fixture()
    test =Account.update_user(user, @invalid_attrs)
    Logger.info(">>>>>>>>>#{inspect(test)}")
    assert {:error, %Ecto.Changeset{}} = Account.update_user(user, @invalid_attrs)
    assert %{user | password: nil} == Account.get_user!(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = user_fixture()
    assert {:ok, %User{}} = Account.delete_user(user)
    assert_raise Ecto.NoResultsError, fn -> Account.get_user!(user.id) end
  end

  test "change_user/1 returns a user changeset" do
    user = user_fixture()
    assert %Ecto.Changeset{} = Account.change_user(user)
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
