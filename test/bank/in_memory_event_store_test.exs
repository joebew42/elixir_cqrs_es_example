defmodule Bank.InMemoryEventStoreTest do
  use ExUnit.Case, async: true

  import Mox

  defmodule AnEvent do
    defstruct [:id, :data]
  end

  alias Bank.EventPublisherMock, as: EventPublisher

  alias Bank.InMemoryEventStore, as: EventStore

  setup do
    Application.start(:mox)
    Mox.set_mox_global
    :ok
  end

  setup do
    stub(EventPublisher, :publish, fn(_an_event) -> :ok end)

    start_supervised(EventStore)
    :ok
  end

  test "returns not found when there are no events" do
    result = EventStore.load_event_stream("AN_AGGREGATE_ID")

    assert result == {:error, :not_found}
  end

  test "returns the events for a given aggregate" do
    EventStore.append_to_stream("AN_AGGREGATE_ID", -1, [%AnEvent{id: "AN_AGGREGATE_ID"}])

    result = EventStore.load_event_stream("AN_AGGREGATE_ID")

    assert result == {:ok, 0, [%AnEvent{id: "AN_AGGREGATE_ID"}]}
  end

  test "returns a concurrency error when the expected version does not match" do
    EventStore.append_to_stream("AN_AGGREGATE_ID", -1, [%AnEvent{id: "AN_AGGREGATE_ID"}])
    EventStore.append_to_stream("AN_AGGREGATE_ID",  0, [%AnEvent{id: "AN_AGGREGATE_ID"}])

    result = EventStore.append_to_stream("AN_AGGREGATE_ID", 0, [%AnEvent{id: "AN_AGGREGATE_ID"}])

    assert result == {:error, "the expected version: 0 does not match with the actual version: 1"}
  end

  test "returns events in an ascending order and with the correct version progression" do
    EventStore.append_to_stream("AN_AGGREGATE_ID", -1, [%AnEvent{id: "AN_AGGREGATE_ID", data: 1}])
    EventStore.append_to_stream("AN_AGGREGATE_ID",  0, [%AnEvent{id: "AN_AGGREGATE_ID", data: 2}])
    EventStore.append_to_stream("AN_AGGREGATE_ID",  1, [%AnEvent{id: "AN_AGGREGATE_ID", data: 3}])
    EventStore.append_to_stream("AN_AGGREGATE_ID",  2, [%AnEvent{id: "AN_AGGREGATE_ID", data: 5}, %AnEvent{id: "AN_AGGREGATE_ID", data: 4}])

    assert EventStore.load_event_stream("AN_AGGREGATE_ID") == {
      :ok,
      4,
      [
        %AnEvent{id: "AN_AGGREGATE_ID", data: 5},
        %AnEvent{id: "AN_AGGREGATE_ID", data: 4},
        %AnEvent{id: "AN_AGGREGATE_ID", data: 3},
        %AnEvent{id: "AN_AGGREGATE_ID", data: 2},
        %AnEvent{id: "AN_AGGREGATE_ID", data: 1}
      ]
    }
  end

  test "publish events once they are stored" do
    first_event = %AnEvent{id: "AN_AGGREGATE_ID", data: 1}
    last_event = %AnEvent{id: "AN_AGGREGATE_ID", data: 2}

    EventPublisher
    |> expect(:publish, fn ^first_event -> :ok end)
    |> expect(:publish, fn ^last_event -> :ok end)

    EventStore.append_to_stream("AN_AGGREGATE_ID", -1, [last_event, first_event])

    verify!(EventPublisher)
  end
end
