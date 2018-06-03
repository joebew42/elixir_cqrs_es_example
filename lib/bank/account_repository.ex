defmodule Bank.AccountRepository do

  alias Bank.{Account, EventStore}

  def find_by_id(id) do
    case Account.exists?(id) do
      true -> {:ok, id}
      false -> try_to_reload_from_event_stream(id)
    end
  end

  def save(id) do
    :ok = EventStore.append_to_stream(Account.changes(id))
  end

  defp try_to_reload_from_event_stream(id) do
    case EventStore.load_event_stream(id) do
      {:ok, event_stream} ->
        {:ok, id} = Account.load_from_event_stream(event_stream)
        {:ok, id}
      {:error, :not_found} ->
        {:error, :not_found}
    end
  end
end
