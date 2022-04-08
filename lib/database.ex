defmodule Database do
  use GenServer
  import User
  # add(user) (no same email ili username)
  # log in(un i pass)! not log in with more than one user
  # delete user( username)
  # change pass ( username old pass new pass). only loged in user can change pass
  # logout(username)
  # show() all users in database/
  def start_link do
    GenServer.start_link(__MODULE__, [], [{:name, __MODULE__}])
  end

  def init(init_args) do
    {:ok, init_args}
  end

  # Client side

  def find_all do
    GenServer.call(__MODULE__, :find_all)
  end

  def save_user(new_elem) when is_struct(new_elem, User) do
    GenServer.call(__MODULE__, {:save_user, new_elem})
  end

  def delete_user(username) when is_bitstring(username) do
    GenServer.call(__MODULE__, {:delete_user, username})
  end

  # Server side

  def handle_call({:save_user, input}, data) do
    data
    |> Enum.all?(fn user -> not User.compare(user, input) end)
    |> add(input, data)
  end

  def handle_call(:find_all, _from, data) do
    {:reply, data, data}
  end

  def handle_call({:delete_user, name}, _from, data) do
    new_list = Enum.filter(data, fn
          %{username: ^name} -> false
          _user -> true
        end)
    if length(new_list) != length(data) do
      {:reply, :ok, new_list}
    else
      {:reply, {:error, "User with username #{name} does not exist"}, new_list}
    end
  end

  # Private functions

  defp add(true, input, list) do
    result = [input | list]
    {:reply, :ok, result}
  end

  defp add(false, _, list) do
    {:reply, {:error, "Username or email is already taken"}, list}
  end
end
