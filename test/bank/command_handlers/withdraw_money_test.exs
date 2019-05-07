defmodule Bank.CommandHandlers.WithdrawMoneyTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.{Events, Commands}

  alias Bank.EventStoreMock, as: EventStore

  alias Bank.CommandHandlers.WithdrawMoney

  test "nothing is withdrawn if the account does not exist" do
    EventStore
    |> expect(:load_event_stream, fn "AN ID" -> {:error, :not_found} end)
    |> expect_never(:append_to_stream, fn "AN ID", 0, [%Events.MoneyWithdrawn{id: "AN ID", amount: 100}] -> :ok end)

    :nothing = WithdrawMoney.handle(%Commands.WithdrawMoney{account_id: "AN ID", amount: 100})

    verify!(EventStore)
  end

  test "an amount is withdrawn" do
    EventStore
    |> expect(:load_event_stream, fn "AN ID" -> {:ok, 1, [%Events.AccountCreated{id: "AN ID", name: "A NAME"}, %Events.MoneyDeposited{id: "AN ID", amount: 100}]} end)
    |> expect(:append_to_stream, fn "AN ID", 1, [%Events.MoneyWithdrawn{id: "AN ID", amount: 100}] -> :ok end)

    :ok = WithdrawMoney.handle(%Commands.WithdrawMoney{account_id: "AN ID", amount: 100})

    verify!(EventStore)
  end

  test "withdraw is declined due insufficient funds" do
    EventStore
    |> expect(:load_event_stream, fn "AN ID" -> {:ok, 1, [%Events.AccountCreated{id: "AN ID", name: "A NAME"}, %Events.MoneyDeposited{id: "AN ID", amount: 10}]} end)
    |> expect(:append_to_stream, fn "AN ID", 1, [%Events.MoneyWithdrawalDeclined{id: "AN ID", amount: 100}] -> :ok end)

    :ok = WithdrawMoney.handle(%Commands.WithdrawMoney{account_id: "AN ID", amount: 100})

    verify!(EventStore)
  end

  defp expect_never(mock, function_name, function) do
    expect(mock, function_name, 0, function)
  end
end