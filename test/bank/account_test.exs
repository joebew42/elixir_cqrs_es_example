defmodule Bank.AccountTest do
  use ExUnit.Case, async: true

  alias Bank.Events
  alias Bank.Account

  describe "#new" do
    test "produces an AccountCreated change" do
      account =
        %Account{}
        |> Account.new("Joe")

      assert account |> contain_change?(%Events.AccountCreated{id: "Joe"})
    end
  end

  describe "#deposit" do
    test "produces a MoneyDeposited change" do
      account =
        %Account{}
        |> Account.new("Joe")
        |> Account.deposit(100)

      assert account |> contain_change?(%Events.MoneyDeposited{id: "Joe", amount: 100})
    end
  end

  describe "#withdraw" do
    test "produces a MoneyWithdrawalDeclined if there is no sufficient funds" do
      account =
        %Account{}
        |> Account.new("Joe")
        |> Account.withdraw(100)

      assert account |> contain_change?(%Events.MoneyWithdrawalDeclined{id: "Joe", amount: 100})
    end

    test "produces a MoneyWithdrawn" do
      account =
        %Account{}
        |> Account.new("Joe")
        |> Account.deposit(100)
        |> Account.withdraw(100)

      assert account |> contain_change?(%Events.MoneyWithdrawn{id: "Joe", amount: 100})
    end
  end

  describe "#transfer" do
    test "produces a TransferOperationOpened when enough funds are available" do
      account =
        %Account{}
        |> Account.new("Joe")
        |> Account.deposit(100)
        |> Account.transfer(100, "A_PAYEE", "AN_OPERATION_ID")

      expected_change =
        %Events.TransferOperationOpened{
          id: "Joe",
          amount: 100,
          payee: "A_PAYEE",
          operation_id: "AN_OPERATION_ID"
        }

      assert account |> contain_change?(expected_change)
    end

    test "produces a TransferOperationDeclined due insufficient funds" do
      account =
        %Account{}
        |> Account.new("Joe")
        |> Account.transfer(100, "A_PAYEE", "AN_OPERATION_ID")

      expected_change =
        %Events.TransferOperationDeclined{
          id: "Joe",
          amount: 100,
          payee: "A_PAYEE",
          operation_id: "AN_OPERATION_ID",
          reason: "insufficient funds"
        }

      assert account |> contain_change?(expected_change)
    end
  end

  describe "#load_from_events" do
    test "load the state from events" do
      events = [
        %Events.MoneyWithdrawn{id: "Joe", amount: 50},
        %Events.MoneyDeposited{id: "Joe", amount: 100},
        %Events.AccountCreated{id: "Joe"},
      ]

      assert Account.load_from_events(events) == %Account{
        id: "Joe",
        available_balance: 50,
        account_balance: 50,
        changes: []
      }
    end
  end

  defp contain_change?(account, event) do
    assert Enum.member?(account.changes, event)
  end
end
