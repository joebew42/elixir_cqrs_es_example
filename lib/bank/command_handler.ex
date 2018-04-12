defmodule Bank.CommandHandler do
  use GenServer

  alias Bank.Commands.CreateAccount
  alias Bank.EventStore
  alias Bank.Account

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: :command_handler)
  end

  def init(nil) do
    {:ok, nil}
  end

  def handle_call(command = %CreateAccount{}, _pid, nil) do
    {:ok, pid} = Account.create(command.id)

    {:ok, _version} = EventStore.append_to_stream(command.id, -1, Account.changes(pid))

    {:reply, :ok, nil}
  end
end