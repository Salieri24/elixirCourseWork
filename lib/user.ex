defmodule User do
  @enforce_keys [:username, :email, :password]
  defstruct @enforce_keys ++ [:sex, is_logged_in: false]

  def compare(%User{username: username1, email: email1}, %User{username: username2, email: email2}) do
    username1 == username2 or email1 == email2
  end

  def checkCred(%User{username: username1, password: password1} = u, username2, password2)do
    if username1 == username2 and password1 == password2 do
      u
    else
      nil
    end
  end

  def checkCred(nil, _, _)do
    nil
  end

end
