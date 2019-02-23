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
  def handle_call({:append_to_stream, aggregate_id, expected_version, changes}, _from, state) do
    event_descriptors = Map.get(state, aggregate_id, [])

    concurrency_check =
      case actual_version_of(event_descriptors) do
        actual_version when actual_version != expected_version ->
          {:error, "the expected version: #{expected_version} does not match with the actual version: #{actual_version}"}

        _ ->
          :ok
      end

    new_state =
      case concurrency_check do
        {:error, _message} ->
          state

        :ok ->
          updated_event_descriptors = to_event_descriptors(changes, expected_version + 1, []) ++ event_descriptors
          Map.put(state, aggregate_id, updated_event_descriptors)
      end

    {:reply, concurrency_check, new_state}
  end

  defp to_event_descriptors([], _next_version, event_descriptors) do
    Enum.reverse(event_descriptors)
  end

  defp to_event_descriptors([change|changes_left], next_version, event_descriptors) do
    to_event_descriptors(changes_left, next_version + 1, [to_event_descriptor(next_version, change) | event_descriptors])
  end

  defp to_event_descriptor(version, change) do
    %EventDescriptor{
      version: version,
      event_data: change
    }
  end

  defp event_stream_from(event_descriptors) do
    event_descriptors
    |> Enum.map(& &1.event_data)
  end

  defp actual_version_of([]) do
    -1
  end

  defp actual_version_of([last_event_descriptor | _others]) do
    last_event_descriptor.version
  end
end
