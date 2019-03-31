defmodule Bank.Supervisor do
  use Supervisor

  def start_link([command_handlers: command_handlers]) do
    Supervisor.start_link(__MODULE__, [command_handlers: command_handlers], [])
  end

  def init([command_handlers: command_handlers]) do
    children = [
      Bank.EventBus,
      Bank.EventHandler,
      Bank.CommandBus,
      {Bank.CommandDispatcher, command_handlers: command_handlers},
      Bank.InMemoryEventStore,
      Bank.InMemoryAccountReadModel
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
