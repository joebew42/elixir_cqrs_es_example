defmodule Bank.CommandBusTest do
  use ExUnit.Case, async: true

  setup_all do
    {:ok, _pid} = start_supervised Bank.CommandBus
    :ok
  end

  test "not subscribed handler do not receive events" do
    Bank.CommandBus.publish({:create_account, "joe"})

    refute_receive {:create_account, "joe"}
  end

  test "subscribed handler receive events" do
    Bank.CommandBus.subscribe(self())

    Bank.CommandBus.publish({:create_account, "joe"})

    assert_receive {_, _, {:create_account, "joe"}}
  end
end
