defmodule Bank.Accounts do

  alias Bank.EventStore
  alias Bank.Account

  def create_account(name) do
    case EventStore.load_event_stream(name) do
      {:error, :not_found} ->
        {:ok, pid} = Account.new
        Account.create(pid, name)

        EventStore.append_to_stream(name, -1, Account.changes(pid))
      {:ok, _event_stream} ->
        nil
    end

    :ok
  end

  def deposit_money(name, amount) do
    {:ok, event_stream} = EventStore.load_event_stream(name)

    {:ok, pid} = Account.new
    Account.load_from_event_stream(pid, event_stream)
    Account.deposit(pid, amount)

    {:ok} = EventStore.append_to_stream(name, event_stream.version, Account.changes(pid))

    :ok
  end
end