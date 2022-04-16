defmodule Database do
  defstruct is_logged_in: false, users: %{}
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, [{:name, __MODULE__}])
  end

  def init(init_args) do
    {:ok, init_args}
  end

  # Client side

  def show do
    GenServer.call(__MODULE__, :show)
  end

  def save_user(new_elem) when is_struct(new_elem, User) do
    GenServer.call(__MODULE__, {:save_user, new_elem})
  end

  def delete_user(username) when is_bitstring(username) do
    GenServer.cast(__MODULE__, {:delete_user, username})
  end

  def login(username, password) when is_bitstring(username) and is_bitstring(password) do
    GenServer.call(__MODULE__, {:login, username, password})
  end

  def logout(username) when is_bitstring(username) do
    GenServer.call(__MODULE__, {:logout, username})
  end

  def change_password(username, old_password, new_password)
      when is_bitstring(username) and is_bitstring(old_password) and is_bitstring(new_password) do
    GenServer.call(__MODULE__, {:change_password, username, old_password, new_password})
  end

  # Server side

  def handle_call(:show, _from, 
  %__MODULE__{users: data} = state) do
    {:reply, {:ok, data}, state}
  end

  def handle_call({:save_user, input}, _from, 
  %__MODULE__{users: data} = state) do
    data
    |> Map.values()
    |> Enum.all?(fn user -> not User.compare(user, input) end)
    |> add(input, state)
  end

  def handle_call({:login, username, password}, _from, 
  %__MODULE__{is_logged_in: false, users: data} = state) do
    data
    |> Map.get(username)
    |> User.checkCred(username, password)
    |> logIn(state)
  end

  def handle_call({:login, _, _}, _from, 
  %__MODULE__{is_logged_in: true} = state) do
    {:reply, {:error, "An user is already logged in!"}, state}
  end

  def handle_call({:logout, username},_from,
  %__MODULE__{is_logged_in: true, users: data} = state) do
    data
    |> Map.get(username)
    |> logOut(state)
  end

  def handle_call({:logout, _}, _from, 
  %__MODULE__{is_logged_in: false} = state) do
    {:reply, {:error, "Noone is logged in!"}, state}
  end

  def handle_call({:change_password, username, old_password, new_password},_from,
  %__MODULE__{is_logged_in: true, users: data} = state) do
    data
    |> Map.get(username)
    |> User.checkCred(username, old_password)
    |> changePass(new_password, state)
  end

  def handle_call({:change_password, _, _, _}, _from, 
  %__MODULE__{is_logged_in: false} = state) do
    {:reply, {:error, "Log in to change your password!"}, state}
  end

  def handle_cast({:delete_user, name}, 
  %__MODULE__{is_logged_in: is_in, users: data}) do
    new_data = Map.delete(data, name)
    {:noreply, %__MODULE__{is_logged_in: is_in, users: new_data}}
  end

  # Private functions

  defp add(true, %User{username: name} = u, 
  %__MODULE__{is_logged_in: is_in, users: data}) do
    new_data = Map.put(data, name, u)
    {:reply, {:ok, "User added"}, %__MODULE__{is_logged_in: is_in, users: new_data}}
  end

  defp add(false, _, state) do
    {:reply, {:error, "Username or email is already taken."}, state}
  end

  defp logIn(%User{username: name} = u, %__MODULE__{users: data}) do
    new_data = Map.put(data, name, %User{u | is_logged_in: true})
    {:reply, {:ok, "Logged in"}, %__MODULE__{is_logged_in: true, users: new_data}}
  end

  defp logIn(nil, state) do
    {:reply, {:error, "User with such info does not exist."}, state}
  end

  defp logOut(%User{username: name, is_logged_in: true} = u, %__MODULE__{users: data}) do
    new_data = Map.put(data, name, %User{u | is_logged_in: false})
    {:reply, {:ok, "Logged out"}, %__MODULE__{is_logged_in: false, users: new_data}}
  end

  defp logOut(%User{is_logged_in: false}, state) do
    {:reply, {:error, "This user is not logged in."}, state}
  end

  defp logOut(nil, state) do
    {:reply, {:error, "User with such info does not exist."}, state}
  end

  defp changePass(%User{username: name} = u, new_pass, %__MODULE__{
         is_logged_in: is_in,
         users: data
       }) do
    new_data = Map.put(data, name, %User{u | password: new_pass})
    {:reply, {:ok, "Password changed"}, %__MODULE__{is_logged_in: is_in, users: new_data}}
  end

  defp changePass(nil, _, state) do
    {:reply, {:error, "User with such info does not exist."}, state}
  end
end
