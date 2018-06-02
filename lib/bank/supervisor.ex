defmodule Bank.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: Bank.Registry},
      Bank.EventBus,
      Bank.CommandBus,
      Bank.CommandHandler
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
