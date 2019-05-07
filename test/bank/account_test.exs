defmodule Bank.AccountTest do
  use ExUnit.Case, async: true

  alias Bank.Events
  alias Bank.Account

  describe "#new" do
    test "produces an AccountCreated change" do
      account =
        %Account{}
        |> Account.new("AN ID", "A NAME")

      assert account |> contain_change?(%Events.AccountCreated{id: "AN ID", name: "A NAME"})
      assert account.id == "AN ID"
      assert account.name == "A NAME"
    end
  end

  describe "#deposit" do
    test "produces a MoneyDeposited change" do
      account =
        %Account{}
        |> Account.new("AN ID", "A NAME")
        |> Account.deposit(100)

      assert account |> contain_change?(%Events.MoneyDeposited{id: "AN ID", amount: 100})
    end
  end

  describe "#withdraw" do
    test "produces a MoneyWithdrawalDeclined if there is no sufficient funds" do
      account =
        %Account{}
        |> Account.new("AN ID", "A NAME")
        |> Account.withdraw(100)

      assert account |> contain_change?(%Events.MoneyWithdrawalDeclined{id: "AN ID", amount: 100})
    end

    test "produces a MoneyWithdrawn" do
      account =
        %Account{}
        |> Account.new("AN ID", "A NAME")
        |> Account.deposit(100)
        |> Account.withdraw(100)

      assert account |> contain_change?(%Events.MoneyWithdrawn{id: "AN ID", amount: 100})
    end
  end

  describe "#transfer" do
    test "produces a TransferOperationOpened when enough funds are available" do
      account =
        %Account{}
        |> Account.new("AN ID", "A NAME")
        |> Account.deposit(100)
        |> Account.transfer(100, "A_PAYEE", "AN_OPERATION_ID")

      expected_change =
        %Events.TransferOperationOpened{
          id: "AN ID",
          amount: 100,
          payee: "A_PAYEE",
          operation_id: "AN_OPERATION_ID"
        }

      assert account |> contain_change?(expected_change)
      assert account.available_balance == 100
      assert account.account_balance == 0
    end

    test "produces a TransferOperationDeclined due insufficient funds" do
      account =
        %Account{}
        |> Account.new("AN ID", "A NAME")
        |> Account.deposit(50)
        |> Account.transfer(100, "A_PAYEE", "AN_OPERATION_ID")

      expected_change =
        %Events.TransferOperationDeclined{
          id: "AN ID",
          amount: 100,
          payee: "A_PAYEE",
          operation_id: "AN_OPERATION_ID",
          reason: "insufficient funds"
        }

      assert account |> contain_change?(expected_change)
      assert account.available_balance == 50
      assert account.account_balance == 50
    end
  end

  describe "#confirm_transfer_operation" do
    test "produces a TransferOperationConfirmed and update the balance" do
      account =
        %Account{}
        |> Account.new("AN ID", "A NAME")
        |> Account.confirm_transfer_operation(100, "A_PAYER", "AN_OPERATION_ID")

      expected_change =
        %Events.TransferOperationConfirmed{
          id: "AN ID",
          amount: 100,
          payer: "A_PAYER",
          operation_id: "AN_OPERATION_ID"
        }

      assert account |> contain_change?(expected_change)
      assert account.available_balance == 100
      assert account.account_balance == 100
    end
  end

  describe "#complete_transfer_operation" do
    test "produces a TransferOperationCompleted and update the balance" do
      account =
        %Account{}
        |> Account.new("AN ID", "A NAME")
        |> Account.deposit(100)
        |> Account.transfer(50, "A_PAYEE", "AN_OPERATION_ID")
        |> Account.complete_transfer_operation(50, "A_PAYEE", "AN_OPERATION_ID")

      expected_change =
        %Events.TransferOperationCompleted{
          id: "AN ID",
          amount: 50,
          payee: "A_PAYEE",
          operation_id: "AN_OPERATION_ID"
        }

      assert account |> contain_change?(expected_change)
      assert account.available_balance == 50
      assert account.account_balance == 50
    end
  end

  describe "#load_from_events" do
    test "load the state from events" do
      events = [
        %Events.MoneyWithdrawn{id: "AN ID", amount: 50},
        %Events.MoneyDeposited{id: "AN ID", amount: 100},
        %Events.AccountCreated{id: "AN ID", name: "A NAME"},
      ]

      assert Account.load_from_events(events) == %Account{
        id: "AN ID",
        name: "A NAME",
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
