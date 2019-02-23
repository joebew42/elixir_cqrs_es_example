defmodule Bank.InMemoryEventStore do
  @behaviour Bank.EventStore

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl Bank.EventStore
  def load_event_stream(aggregate_id) do
    GenServer.call(__MODULE__, {:load_event_stream, aggregate_id})
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
  def handle_call({:load_event_stream, aggregate_id}, _from, state) do
    reply = case Map.get(state, aggregate_id) do
      nil ->
        {:error, :not_found}
      events ->
        {:ok, 0, events}
    end

    {:reply, reply, state}
  end

  @impl true
  def handle_call({:append_to_stream, aggregate_id, _version, changes}, _from, state) do
    events = Map.get(state, aggregate_id, [])
    updated_events = changes ++ events

    new_state = Map.put(state, aggregate_id, updated_events)

    {:reply, :ok, new_state}
  end
end
