defmodule Bank.CommandDispatcher do
  use GenServer

  alias Bank.{Commands, CommandHandlers}

  @default_handlers %{
    Commands.CreateAccount => CommandHandlers.CreateAccount,
    Commands.DepositMoney  => CommandHandlers.DepositMoney,
    Commands.WithdrawMoney => CommandHandlers.WithdrawMoney
  }

  def start_link([]) do
    start_link(handlers: @default_handlers)
  end

  def start_link(handlers: handlers) do
    GenServer.start_link(__MODULE__, handlers, name: :command_dispatcher)
  end

  def init(handlers) do
    Bank.CommandBus.subscribe(self())

    {:ok, handlers}
  end

  def handle_cast(command, handlers) do
    command_handler = handler_for(command.__struct__, handlers)

    Task.Supervisor.start_child(Bank.TaskSupervisor, fn() ->
      command_handler.handle(command)
    end)

    {:noreply, handlers}
  end

  defp handler_for(command_name, handlers) do
    Map.get(handlers, command_name, CommandHandlers.Null)
  end
end
