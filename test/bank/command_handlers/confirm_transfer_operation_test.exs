defmodule Bank.CommandHandlers.ConfirmTransferOperationTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.{Events, Commands}

  alias Bank.EventStoreMock, as: EventStore

  alias Bank.CommandHandlers.ConfirmTransferOperation

  test "a transfer operation is confirmed" do
    EventStore
    |> expect(:load_event_stream, fn "Joe" -> {:ok, 0, [%Events.AccountCreated{id: "Joe"}]} end)
    |> expect(:append_to_stream, fn "Joe", 0, [%Events.TransferOperationConfirmed{id: "Joe", amount: 50, payer: "Someone", operation_id: "an_operation_id"}] -> :ok end)

    command =
      %Commands.ConfirmTransferOperation{
        id: "Joe",
        amount: 50,
        payer: "Someone",
        operation_id: "an_operation_id"
      }

    :ok = ConfirmTransferOperation.handle(command)

    verify!(EventStore)
  end
end