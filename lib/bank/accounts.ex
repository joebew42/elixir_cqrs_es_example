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
end