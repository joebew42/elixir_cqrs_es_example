defmodule Bank.AccountRepositoryTest do
  use ExUnit.Case, async: true

  import Mock

  alias Bank.Events.AccountCreated
  alias Bank.{Account, EventStore, EventStream}

  alias Bank.AccountRepository

  describe "#find_by_id" do
    test "build an account starting from existing events" do
      with_mock EventStore,
        [load_event_stream: fn(_) -> {:ok, %EventStream{version: 0, events: [%AccountCreated{id: "Joe"}]}} end,
         append_to_stream: fn(_) -> :ok end]
      do
        {:ok, _id} = AccountRepository.find_by_id("Joe")

        assert called EventStore.load_event_stream("Joe")
        assert not called EventStore.append_to_stream(%EventStream{})
      end
    end
  end

  describe "#save" do
    test "stores all the uncommitted changes of an account" do
      with_mock EventStore, [append_to_stream: fn(_) -> :ok end] do
        {:ok, id} = Account.new("Joe")

        :ok = AccountRepository.save(id)

        assert called EventStore.append_to_stream(%EventStream{
          id: "Joe", version: 0,
          events: [%AccountCreated{id: "Joe"}]
        })
      end
    end
  end

end
