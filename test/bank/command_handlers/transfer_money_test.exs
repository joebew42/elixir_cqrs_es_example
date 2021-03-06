defmodule Bank.CommandHandlers.TransferMoneyTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.{Events, Commands}

  alias Bank.EventStoreMock, as: EventStore

  alias Bank.CommandHandlers.TransferMoney

  test "nothing to transfer if the account does not exist" do
    EventStore
    |> expect(:load_event_stream, fn "AN ID" -> {:error, :not_found} end)
    |> expect_never(:append_to_stream, fn "AN ID", 0, [%Events.TransferOperationOpened{id: "AN ID", amount: 50, payee: "PAYEE ID", operation_id: "an_operation_id"}] -> :ok end)

    command =
      %Commands.TransferMoney{
        account_id: "AN ID",
        amount: 50,
        payee: "PAYEE ID",
        operation_id: "an_operation_id"
      }

    :nothing = TransferMoney.handle(command)

    verify!(EventStore)
  end

  test "a transfer operation is opened when the account exist and has enough money" do
    EventStore
    |> expect(:load_event_stream, fn "AN ID" -> {:ok, 1, [%Events.AccountCreated{id: "AN ID", name: "A NAME"}, %Events.MoneyDeposited{id: "AN ID", amount: 100}]} end)
    |> expect(:append_to_stream, fn "AN ID", 1, [%Events.TransferOperationOpened{id: "AN ID", amount: 50, payee: "PAYEE ID", operation_id: "an_operation_id"}] -> :ok end)

    command =
      %Commands.TransferMoney{
        account_id: "AN ID",
        amount: 50,
        payee: "PAYEE ID",
        operation_id: "an_operation_id"
      }

    :ok = TransferMoney.handle(command)

    verify!(EventStore)
  end

  defp expect_never(mock, function_name, function) do
    expect(mock, function_name, 0, function)
  end
end