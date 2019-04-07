defmodule Bank.TransferOperationProcessManagerTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.Events

  alias Bank.TransferOperationProcessManager, as: ProcessManager

  describe "on TransferOperationOpened" do
    setup do
      transfer_operation_opened =
        %Events.TransferOperationOpened{
          id: "payer_account",
          amount: 100,
          payee: "payee_account",
          operation_id: "OPERATION_ID"
        }

      %{event: transfer_operation_opened}
    end

    test "the operation goes to the state pending_confirmation", %{event: transfer_operation_opened} do
      new_state = ProcessManager.on(transfer_operation_opened, %{})

      assert new_state == %{
        "OPERATION_ID" => :pending_confirmation
      }
    end

    test "a command is sent to the payee to confirm the operation", %{event: transfer_operation_opened} do
      command = %Bank.Commands.ConfirmTransferOperation{
        id: transfer_operation_opened.payee,
        payer: transfer_operation_opened.id,
        amount: transfer_operation_opened.amount,
        operation_id: transfer_operation_opened.operation_id
      }

      expect(Bank.CommandBus, :publish, fn(^command) -> :ok end)

      ProcessManager.on(transfer_operation_opened, %{})

      verify!(Bank.CommandBus)
    end
  end
end