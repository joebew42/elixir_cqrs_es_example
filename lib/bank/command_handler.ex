defmodule Bank.CommandHandler do
  use GenServer

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney}
  alias Bank.Account

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: :command_handler)
  end

  def init(nil) do
    Bank.CommandBus.subscribe(self())
    {:ok, nil}
  end

  def handle_cast(%CreateAccount{} = command, nil) do
    create_account_command_handler_handle(command)

    {:noreply, nil}
  end

  def handle_cast(%DepositMoney{} = command, nil) do
    deposit_money_command_handler_handle(command)

    {:noreply, nil}
  end

  def handle_cast(%WithdrawMoney{} = command, nil) do
    withdraw_money_command_handler_handle(command)

    {:noreply, nil}
  end

  defp create_account_command_handler_handle(command) do
    case event_store().load_event_stream(command.id) do
      {:ok, _version, _changes} ->
        :nothing
      {:error, :not_found} ->
        account =
          %Account{}
          |> Account.new(command.id)

        :ok = event_store().append_to_stream(command.id, -1, account.changes)
    end
  end

  defp deposit_money_command_handler_handle(command) do
    case event_store().load_event_stream(command.id) do
      {:ok, version, events} ->
        account =
          Account.load_from_events(events)
          |> Account.deposit(command.amount)

        :ok = event_store().append_to_stream(command.id, version, account.changes)
      {:error, :not_found} ->
        :nothing
    end
  end

  defp withdraw_money_command_handler_handle(command) do
    case event_store().load_event_stream(command.id) do
      {:ok, version, events} ->
        account =
          Account.load_from_events(events)
          |> Account.withdraw(command.amount)

        :ok = event_store().append_to_stream(command.id, version, account.changes)
      {:error, :not_found} ->
        :nothing
    end
  end

  defp event_store() do
    Application.get_env(:elixir_cqrs_es_example, :event_store)
  end
end
