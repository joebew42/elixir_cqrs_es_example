defmodule Bank.TransferOperationServerTest do
  use ExUnit.Case

  import Mox

  alias Bank.ProcessManagerMock, as: ProcessManager

  setup do
    Mox.set_mox_global

    start_supervised Bank.EventBus
    start_supervised Bank.TransferOperationServer

    :ok
  end

  test "delegates the process manager to handle the event" do
    expect(ProcessManager, :on, fn _event, _state -> %{} end)

    publish("AN EVENT")

    verify!(ProcessManager)
  end

  defp publish(event) do
    Bank.EventBus.publish(event)
    Process.sleep(100)
  end
end