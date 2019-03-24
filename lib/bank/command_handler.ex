defmodule Bank.CommandHandler do
  use GenServer

  alias Bank.{Commands, CommandHandlers}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: :command_handler)
  end

  def init(nil) do
    Bank.CommandBus.subscribe(self())
    {:ok, nil}
  end

  def handle_cast(%Commands.CreateAccount{} = command, nil) do
    CommandHandlers.CreateAccount.handle(command)

    {:noreply, nil}
  end

  def handle_cast(%Commands.DepositMoney{} = command, nil) do
    CommandHandlers.DepositMoney.handle(command)

    {:noreply, nil}
  end

  def handle_cast(%Commands.WithdrawMoney{} = command, nil) do
    CommandHandlers.WithdrawMoney.handle(command)

    {:noreply, nil}
  end
end
