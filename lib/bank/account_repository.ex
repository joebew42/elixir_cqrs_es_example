defmodule Bank.AccountRepository do

  alias Bank.{Account, EventStore}

  def find_by_id(id) do
    {:ok, event_stream} = EventStore.load_event_stream(id)

    {:ok, id} = Account.load_from_event_stream(event_stream)

    {:ok, id}
  end

  def save(id) do
    :ok = EventStore.append_to_stream(Account.changes(id))
  end
end
