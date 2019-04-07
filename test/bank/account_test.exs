defmodule Bank.AccountTest do
  use ExUnit.Case, async: true

  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined, MoneyWithdrawn}
  alias Bank.Account

  describe "#new" do
    test "produces an AccountCreated change" do
      account =
        %Account{}
        |> Account.new("Joe")

      assert account |> contain_change?(%AccountCreated{id: "Joe"})
    end
  end

  describe "#deposit" do
    test "produces a MoneyDeposited change" do
      account =
        %Account{}
        |> Account.new("Joe")
        |> Account.deposit(100)

      assert account |> contain_change?(%MoneyDeposited{id: "Joe", amount: 100})
    end
  end

  describe "#withdraw" do
    test "produces a MoneyWithdrawalDeclined if there is no sufficient funds" do
      account =
        %Account{}
        |> Account.new("Joe")
        |> Account.withdraw(100)

      assert account |> contain_change?(%MoneyWithdrawalDeclined{id: "Joe", amount: 100})
    end

    test "produces a MoneyWithdrawn" do
      account =
        %Account{}
        |> Account.new("Joe")
        |> Account.deposit(100)
        |> Account.withdraw(100)

      assert account |> contain_change?(%MoneyWithdrawn{id: "Joe", amount: 100})
    end
  end

  describe "#load_from_events" do
    test "load the state from events" do
      events = [
        %MoneyWithdrawn{id: "Joe", amount: 50},
        %MoneyDeposited{id: "Joe", amount: 100},
        %AccountCreated{id: "Joe"},
      ]

      assert Account.load_from_events(events) == %Account{id: "Joe", amount: 50, changes: []}
    end
  end

  defp contain_change?(account, event) do
    assert Enum.member?(account.changes, event)
  end
end
