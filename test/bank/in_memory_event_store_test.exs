defmodule Bank.InMemoryEventStoreTest do
  use ExUnit.Case, async: true

  alias Bank.InMemoryEventStore, as: EventStore

  describe "load_event_stream/1" do
    test "returns not found when there are no events" do
      result = EventStore.load_event_stream("AN_AGGREGATE_ID")

      assert result == {:error, :not_found}
    end
  end

end