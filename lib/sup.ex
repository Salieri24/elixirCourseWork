defmodule Sup do
  use Supervisor
  def start_link do
    Supervisor.start_link(__MODULE__, [{:name, __MODULE__}])
  end

  def init(_init_args) do
    children = [
      {Database, {false, %{}}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
