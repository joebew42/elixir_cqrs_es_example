defmodule Bank.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, [])
  end

  def init(_args) do
    children = [
      Bank.EventBus,
      Bank.EventHandler,
      Bank.TransferOperationServer,
      Bank.InMemoryEventStore,
      Bank.InMemoryAccountReadModel
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
