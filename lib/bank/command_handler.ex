defmodule Bank.CommandHandler do
  use GenServer

  alias Bank.{Commands, CommandHandlers}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: :command_handler)
  end

  def init(nil) do
    Bank.CommandBus.subscribe(self())
    {:ok, %{
      Commands.CreateAccount => CommandHandlers.CreateAccount,
      Commands.DepositMoney  => CommandHandlers.DepositMoney,
      Commands.WithdrawMoney => CommandHandlers.WithdrawMoney
    }}
  end

  def handle_cast(command, handlers) do
    command_handler = handler_for(command.__struct__, handlers)

    command_handler.handle(command)

    {:noreply, handlers}
  end

  defp handler_for(command_name, handlers) do
    Map.get(handlers, command_name)
  end
end
