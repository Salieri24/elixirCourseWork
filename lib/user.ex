defmodule User do
  @enforce_keys [:username]
  defstruct @enforce_keys ++ [:email,:password, :sex, :is_logged_in]

  def compare(%User{username: username1, email: email1}, %User{username: username2, email: email2}) do
    username1 == username2 or email1 == email2
  end
  def get_username(%User{username: name}) do
    name
  end
end
