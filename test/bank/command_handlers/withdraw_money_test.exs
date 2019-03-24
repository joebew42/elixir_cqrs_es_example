defmodule Bank.CommandHandlers.WithdrawMoneyTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.{Events, Commands}

  alias Bank.EventStoreMock, as: EventStore

  alias Bank.CommandHandlers.WithdrawMoney

  test "nothing is withdrawn if the account does not exist" do
    EventStore
    |> expect(:load_event_stream, fn "Joe" -> {:error, :not_found} end)
    |> expect_never(:append_to_stream, fn "Joe", 0, [%Events.MoneyWithdrawn{id: "Joe", amount: 100}] -> :ok end)

    :nothing = WithdrawMoney.handle(%Commands.WithdrawMoney{id: "Joe", amount: 100})

    verify!(EventStore)
  end

  test "an amount is withdrawn" do
    EventStore
    |> expect(:load_event_stream, fn "Joe" -> {:ok, 1, [%Events.AccountCreated{id: "Joe"}, %Events.MoneyDeposited{id: "Joe", amount: 100}]} end)
    |> expect(:append_to_stream, fn "Joe", 1, [%Events.MoneyWithdrawn{id: "Joe", amount: 100}] -> :ok end)

    :ok = WithdrawMoney.handle(%Commands.WithdrawMoney{id: "Joe", amount: 100})

    verify!(EventStore)
  end

  test "withdraw is declined due insufficient funds" do
    EventStore
    |> expect(:load_event_stream, fn "Joe" -> {:ok, 1, [%Events.AccountCreated{id: "Joe"}, %Events.MoneyDeposited{id: "Joe", amount: 10}]} end)
    |> expect(:append_to_stream, fn "Joe", 1, [%Events.MoneyWithdrawalDeclined{id: "Joe", amount: 100}] -> :ok end)

    :ok = WithdrawMoney.handle(%Commands.WithdrawMoney{id: "Joe", amount: 100})

    verify!(EventStore)
  end

  defp expect_never(mock, function_name, function) do
    expect(mock, function_name, 0, function)
  end
end