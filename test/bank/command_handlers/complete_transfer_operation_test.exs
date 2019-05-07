defmodule Bank.CommandHandlers.CompleteTransferOperationTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.{Events, Commands}

  alias Bank.EventStoreMock, as: EventStore

  alias Bank.CommandHandlers.CompleteTransferOperation

  test "a transfer operation is completed" do
    EventStore
    |> expect(:load_event_stream, fn "Joe" -> {:ok, 0, [%Events.AccountCreated{id: "Joe"}]} end)
    |> expect(:append_to_stream, fn "Joe", 0, [%Events.TransferOperationCompleted{id: "Joe", amount: 50, payee: "Someone", operation_id: "an_operation_id"}] -> :ok end)

    command =
      %Commands.CompleteTransferOperation{
        id: "Joe",
        amount: 50,
        payee: "Someone",
        operation_id: "an_operation_id"
      }

    :ok = CompleteTransferOperation.handle(command)

    verify!(EventStore)
  end
end