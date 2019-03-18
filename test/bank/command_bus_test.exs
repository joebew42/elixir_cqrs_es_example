defmodule Bank.CommandBusTest do
  use ExUnit.Case, async: true

  alias Bank.CommandBus

  setup do
    start_supervised CommandBus
    :ok
  end

  test "not subscribed handler do not receive events" do
    CommandBus.publish({:create_account, "joe"})

    refute_receive {:create_account, "joe"}
  end

  test "subscribed handler receive events" do
    CommandBus.subscribe(self())

    CommandBus.publish({:create_account, "joe"})

    assert_receive {_, {:create_account, "joe"}}
  end
end
