defmodule Bank.CommandHandlers.CompleteTransferOperationTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.{Events, Commands}

  alias Bank.EventStoreMock, as: EventStore

  alias Bank.CommandHandlers.CompleteTransferOperation

  test "a transfer operation is completed" do
    EventStore
    |> expect(:load_event_stream, fn "AN ID" -> {:ok, 0, [%Events.AccountCreated{id: "AN ID", name: "A NAME"}]} end)
    |> expect(:append_to_stream, fn "AN ID", 0, [%Events.TransferOperationCompleted{id: "AN ID", amount: 50, payee: "Someone", operation_id: "an_operation_id"}] -> :ok end)

    command =
      %Commands.CompleteTransferOperation{
        account_id: "AN ID",
        amount: 50,
        payee: "Someone",
        operation_id: "an_operation_id"
      }

    :ok = CompleteTransferOperation.handle(command)

    verify!(EventStore)
  end
end