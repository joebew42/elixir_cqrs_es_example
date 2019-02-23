defmodule Bank.InMemoryEventStore do
  @behaviour Bank.EventStore

  defmodule EventDescriptor do
    @enforce_keys [:version, :event_data]
    defstruct [:version, :event_data]
  end

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl Bank.EventStore
  def load_event_stream(aggregate_id) do
    GenServer.call(__MODULE__, {:load_event_stream, aggregate_id})
  end

  @impl Bank.EventStore
  def append_to_stream(aggregate_id, expected_version, changes) do
    GenServer.call(__MODULE__, {:append_to_stream, aggregate_id, expected_version, changes})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:load_event_stream, aggregate_id}, _from, state) do
    reply =
      case Map.get(state, aggregate_id) do
        nil ->
          {:error, :not_found}

        event_descriptors ->
          {:ok, 0, event_stream_from(event_descriptors)}
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_call({:append_to_stream, aggregate_id, _expected_version, changes}, _from, state) do
    event_descriptors = Map.get(state, aggregate_id, [])
    updated_event_descriptors = to_event_descriptors(changes) ++ event_descriptors

    new_state = Map.put(state, aggregate_id, updated_event_descriptors)

    {:reply, :ok, new_state}
  end

  defp to_event_descriptors(changes) do
    changes
    |> Enum.map(&to_event_descriptor/1)
  end

  defp to_event_descriptor(change) do
    %EventDescriptor{
      version: 0,
      event_data: change
    }
  end

  defp event_stream_from(event_descriptors) do
    event_descriptors
    |> Enum.map(& &1.event_data)
  end
end
