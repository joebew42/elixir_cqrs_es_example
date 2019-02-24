defmodule Bank.InMemoryEventStoreTest do
  use ExUnit.Case, async: true

  defmodule AnEvent do
    defstruct [:id, :data]
  end

  alias Bank.InMemoryEventStore, as: EventStore

  setup do
    {:ok, _pid} = start_supervised(EventStore)

    :ok
  end

  describe "load_event_stream/1" do
    test "returns not found when there are no events" do
      result = EventStore.load_event_stream("AN_AGGREGATE_ID")

      assert result == {:error, :not_found}
    end

    test "returns the events for a given aggregate" do
      EventStore.append_to_stream("AN_AGGREGATE_ID", -1, [%AnEvent{id: "AN_AGGREGATE_ID"}])

      result = EventStore.load_event_stream("AN_AGGREGATE_ID")

      assert result == {:ok, 0, [%AnEvent{id: "AN_AGGREGATE_ID"}]}
    end
  end

  describe "append_to_stream/1" do
    test "returns a concurrency error when the expected version does not match" do
      EventStore.append_to_stream("AN_AGGREGATE_ID", -1, [%AnEvent{id: "AN_AGGREGATE_ID"}])
      EventStore.append_to_stream("AN_AGGREGATE_ID",  0, [%AnEvent{id: "AN_AGGREGATE_ID"}])

      result = EventStore.append_to_stream("AN_AGGREGATE_ID", 0, [%AnEvent{id: "AN_AGGREGATE_ID"}])

      assert result == {:error, "the expected version: 0 does not match with the actual version: 1"}
    end
  end

  test "events order and correct version progression" do
    EventStore.append_to_stream("AN_AGGREGATE_ID", -1, [%AnEvent{id: "AN_AGGREGATE_ID", data: 1}])
    EventStore.append_to_stream("AN_AGGREGATE_ID",  0, [%AnEvent{id: "AN_AGGREGATE_ID", data: 2}])
    EventStore.append_to_stream("AN_AGGREGATE_ID",  1, [%AnEvent{id: "AN_AGGREGATE_ID", data: 3}])
    EventStore.append_to_stream("AN_AGGREGATE_ID",  2, [%AnEvent{id: "AN_AGGREGATE_ID", data: 4}])

    assert EventStore.load_event_stream("AN_AGGREGATE_ID") == {
      :ok,
      3,
      [
        %AnEvent{id: "AN_AGGREGATE_ID", data: 1},
        %AnEvent{id: "AN_AGGREGATE_ID", data: 2},
        %AnEvent{id: "AN_AGGREGATE_ID", data: 3},
        %AnEvent{id: "AN_AGGREGATE_ID", data: 4}
      ]
    }
  end
end
