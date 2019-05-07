defmodule Bank.CommandHandlers.ConfirmTransferOperationTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.{Events, Commands}

  alias Bank.EventStoreMock, as: EventStore

  alias Bank.CommandHandlers.ConfirmTransferOperation

  test "a transfer operation is confirmed" do
    EventStore
    |> expect(:load_event_stream, fn "AN ID" -> {:ok, 0, [%Events.AccountCreated{id: "AN ID", name: "A NAME"}]} end)
    |> expect(:append_to_stream, fn "AN ID", 0, [%Events.TransferOperationConfirmed{id: "AN ID", amount: 50, payer: "Someone", operation_id: "an_operation_id"}] -> :ok end)

    command =
      %Commands.ConfirmTransferOperation{
        account_id: "AN ID",
        amount: 50,
        payer: "Someone",
        operation_id: "an_operation_id"
      }

    :ok = ConfirmTransferOperation.handle(command)

    verify!(EventStore)
  end
end