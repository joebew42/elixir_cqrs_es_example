defmodule Bank.AccountsTest do
  use ExUnit.Case, async: true

  import Mock

  alias Bank.{EventStore, EventStream}
  alias Bank.Events.AccountCreated

  alias Bank.Accounts

  test "does not create an account if it already exist" do
    with_mock EventStore,
      [load_event_stream: fn(_) -> {:ok, %EventStream{version: 0, events: [%AccountCreated{id: "Joe"}]}} end,
       append_to_stream: fn(_, _, _) -> {:ok} end]
    do
      :ok = Accounts.create_account("Joe")

      assert called EventStore.load_event_stream("Joe")
      assert not called EventStore.append_to_stream("Joe", -1, [%AccountCreated{id: "Joe"}])
    end
  end

  test "create an account when it does not exist" do
    with_mock EventStore,
     [load_event_stream: fn(_) -> {:error, :not_found} end,
      append_to_stream: fn(_, _, _) -> {:ok} end]
    do
      :ok = Accounts.create_account("Joe")

      assert called EventStore.append_to_stream("Joe", -1, [%AccountCreated{id: "Joe"}])
    end
  end
end