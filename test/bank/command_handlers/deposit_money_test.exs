defmodule Bank.CommandHandlers.DepositMoneyTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.{Events, Commands}

  alias Bank.EventStoreMock, as: EventStore

  alias Bank.CommandHandlers.DepositMoney

  test "an amount is deposited" do
    EventStore
    |> expect(:load_event_stream, fn "AN ID" -> {:ok, 0, [%Events.AccountCreated{id: "AN ID", name: "A NAME"}]} end)
    |> expect(:append_to_stream, fn "AN ID", 0, [%Events.MoneyDeposited{id: "AN ID", amount: 100}] -> :ok end)

    :ok = DepositMoney.handle(%Commands.DepositMoney{account_id: "AN ID", amount: 100})

    verify!(EventStore)
  end

  test "nothing is deposited if the account does not exist" do
    EventStore
    |> expect(:load_event_stream, fn "AN ID" -> {:error, :not_found} end)
    |> expect_never(:append_to_stream, fn "AN ID", 0, [%Events.MoneyDeposited{id: "AN ID", amount: 100}] -> :ok end)

    :nothing = DepositMoney.handle(%Commands.DepositMoney{account_id: "AN ID", amount: 100})

    verify!(EventStore)
  end

  defp expect_never(mock, function_name, function) do
    expect(mock, function_name, 0, function)
  end
end