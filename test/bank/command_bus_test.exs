defmodule Bank.CommandBusTest do
  use ExUnit.Case, async: true

  setup_all do
    {:ok, command_handler_pid} = start_supervised TestableCommandHandler
    {:ok, _pid} = start_supervised Bank.CommandBus

    %{command_handler_pid: command_handler_pid}
  end

  test "not subscribed handler do not receive events" do
    Bank.CommandBus.publish({:create_account, "joe"})

    refute_receive {:create_account, "joe"}
  end

  test "subscribed handler receive events", %{command_handler_pid: command_handler_pid} do
    Bank.CommandBus.subscribe(command_handler_pid)

    Bank.CommandBus.publish({:create_account, "joe"})

    assert TestableCommandHandler.received? {:create_account, "joe"}
  end
end
