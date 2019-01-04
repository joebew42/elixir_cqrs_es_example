defmodule Bank.InMemoryEventStore do
  @behaviour Bank.EventStore

  @impl Bank.EventStore
  def load_event_stream(_aggregate_id) do
    {:error, :not_found}
  end

end