defmodule Bank.InMemoryEventStore do
  @behaviour Bank.EventStore

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl Bank.EventStore
  def load_event_stream(_aggregate_id) do
    {:error, :not_found}
  end

  @impl Bank.EventStore
  def append_to_stream(aggregate_id, version, changes) do
    GenServer.call(__MODULE__, {:append_to_stream, aggregate_id, version, changes})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:append_to_stream, aggregate_id, version, changes}, _from, state) do
    {:reply, :ok, state}
  end
end
