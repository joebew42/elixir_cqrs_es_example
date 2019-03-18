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

  def handle_call(%CreateAccount{id: name}, _pid, nil) do
    result = case event_store().load_event_stream(name) do
      {:ok, _version, _changes} ->
        :ok
      {:error, :not_found} ->
        account =
          %Account{}
          |> Account.new(name)

        :ok = event_store().append_to_stream(name, -1, account.changes)
        :ok
    end

    {:reply, result, nil}
  end

  def handle_call(%DepositMoney{id: name, amount: amount}, _pid, nil) do
    result = case event_store().load_event_stream(name) do
      {:ok, version, events} ->
        account =
          Account.load_from_events(events)
          |> Account.deposit(amount)

        :ok = event_store().append_to_stream(name, version, account.changes)
        :ok
      {:error, :not_found} ->
        :ok
    end

    {:reply, result, nil}
  end

  def handle_call(%WithdrawMoney{id: name, amount: amount}, _pid, nil) do
    result = case event_store().load_event_stream(name) do
      {:ok, version, events} ->
        account =
          Account.load_from_events(events)
          |> Account.withdraw(amount)

        :ok = event_store().append_to_stream(name, version, account.changes)
        :ok
      {:error, :not_found} ->
        :ok
    end

    {:reply, result, nil}
  end

  def handle_call(_unknown_command, _pid, nil) do
    {:reply, {:error, :unknown_command}, nil}
  end

  defp event_store() do
    Application.get_env(:elixir_cqrs_es_example, :event_store)
  end
end
