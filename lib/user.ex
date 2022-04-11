defmodule User do
  @enforce_keys [:username]
  defstruct @enforce_keys ++ [:email,:password, :sex, is_logged_in: false]

  def compare(%User{username: username1, email: email1}, %User{username: username2, email: email2}) do
    username1 == username2 or email1 == email2
  end
  def get_username(%User{username: name}) do
    name
  end
  def attempt_login(%User{username: name, password: pass}=user, username, password) do
    if name == username and pass == password do
      Map.get_and_update(user,:is_logged_in,fn val -> {val, true} end)
    else
      false
    end
  end
  def is_logged_in?(%User{is_logged_in: flag}) do
    flag
  end
end
