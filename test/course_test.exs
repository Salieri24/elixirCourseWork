defmodule DatabaseTest do
  use ExUnit.Case
  doctest Database

  test "create user" do
    Database.start_link(%Database{})

    user = simpleUser("MyUsername", "12345678910")

    assert Database.save_user(user) == {:ok, "User added"}
    user = %User{user | email: "otherEmail@gmail.com"}
    assert Database.save_user(user) == {:error, "Username or email is already taken."}
    user = %User{user | username: "otherName"}
    assert Database.save_user(user) == {:ok, "User added"}
  end

  test "get" do
    Database.start_link(%Database{})

    user = simpleUser("Username", "123456")

    Database.save_user(user)
    assert Database.show() == {:ok, %{"Username" => user}}
  end

  test "delete" do
    Database.start_link(%Database{})

    user = simpleUser("Username", "12345678910")

    Database.save_user(user)
    Database.delete_user("Username")
    assert Database.show() == {:ok, %{}}
  end

  test "login and logout" do
    Database.start_link(%Database{})
    username = "Admin"
    password = "Admin"
    Database.save_user(simpleUser(username, password))
    Database.save_user(simpleUser("usrname", "pass"))

    # Should Fail to logout when not logged in
    assert Database.logout(username) == {:error, "Noone is logged in!"}

    # Should Fail to log in with invalid credentials
    assert Database.login("Invalid Username", password) ==
             {:error, "User with such info does not exist."}

    assert Database.login(username, "Invalid Password") ==
             {:error, "User with such info does not exist."}

    # Should Succeed with correct credentials
    assert Database.login(username, password) == {:ok, "Logged in"}
    # Should Fail to login when already logged in, even with correct credentials
    assert Database.login("Invalid Username", password) ==
             {:error, "An user is already logged in!"}

    assert Database.login("Username", "Password") == {:error, "An user is already logged in!"}
    # Log out : should succeed
    assert Database.logout(username) == {:ok, "Logged out"}
  end

  test "change password" do
    Database.start_link(%Database{})
    username = "Admin"
    password = "Admin"
    Database.save_user(simpleUser(username, password))
    # Should not be able to change password when not logged in
    assert Database.change_password(username, password, "NewPassword") ==
             {:error, "Log in to change your password!"}

    Database.login(username, password)

    # Should succeed when logged in
    assert Database.change_password(username, password, "NewPassword") ==
             {:ok, "Password changed"}

    assert Database.show() ==
             {:ok,
              %{
                username => %User{
                  username: username,
                  password: "NewPassword",
                  email: username,
                  sex: :male,
                  is_logged_in: true
                }
              }}
  end

  defp simpleUser(username, password) do
    %User{
      username: username,
      password: password,
      email: username,
      sex: :male
    }
  end
end
