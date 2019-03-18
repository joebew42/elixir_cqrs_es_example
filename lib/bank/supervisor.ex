defmodule Bank.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      Bank.EventBus,
      Bank.EventHandler,
      Bank.CommandBus,
      Bank.CommandHandler,
      Bank.InMemoryEventStore,
      Bank.InMemoryAccountReadModel
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
