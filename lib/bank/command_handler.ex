defmodule Bank.CommandHandler do
  use GenServer

  alias Bank.Commands.{CreateAccount, DepositMoney}
  alias Bank.{EventStore,  EventStream}
  alias Bank.Account

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: :command_handler)
  end

  def init(nil) do
    {:ok, nil}
  end

  def handle_call(command = %CreateAccount{}, _pid, nil) do
    {:ok, pid} = Account.new
    Account.create(pid, command.id)

    {:ok, _version} = EventStore.append_to_stream(command.id, -1, Account.changes(pid))

    {:reply, :ok, nil}
  end

  def handle_call(command = %DepositMoney{}, _pid, nil) do
    {:ok, event_stream} = EventStore.load_event_stream(command.id)

    {:ok, pid} = Account.new
    Account.load_from_event_stream(pid, event_stream)
    Account.deposit(pid, command.amount)

    {:ok, _version} = EventStore.append_to_stream(command.id, event_stream.version, Account.changes(pid))

    {:reply, :ok, nil}
  end
end