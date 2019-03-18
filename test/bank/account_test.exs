defmodule Bank.AccountTest do
  use ExUnit.Case, async: true

  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined, MoneyWithdrawn}
  alias Bank.Account

  describe "with a new account" do
    setup do
      account = Account.new(%Account{}, "Joe")

      %{account: account}
    end

    test "#new produces an AccountCreated change", %{account: account} do
      assert account |> contain_change?(%AccountCreated{id: "Joe"})
    end

    test "#deposit produces a MoneyDeposited change", %{account: account} do
      account =
        account
        |> Account.deposit(100)

      assert account |> contain_change?(%MoneyDeposited{id: "Joe", amount: 100})
    end

    test "#withdraw produces a MoneyWithdrawalDeclined if there is no sufficient funds", %{account: account} do
      account =
        account
        |> Account.withdraw(100)

      assert account |> contain_change?(%MoneyWithdrawalDeclined{id: "Joe", amount: 100})
    end

    test "#withdraw produces a MoneyWithdrawn", %{account: account} do
      account =
        account
        |> Account.deposit(100)
        |> Account.withdraw(100)

      assert account |> contain_change?(%MoneyWithdrawn{id: "Joe", amount: 100})
    end
  end

  test "#load_from_events load the state from events" do
    events = [
      %MoneyWithdrawn{id: "Joe", amount: 50},
      %MoneyDeposited{id: "Joe", amount: 100},
      %AccountCreated{id: "Joe"},
    ]

    assert Account.load_from_events(events) == %Account{id: "Joe", amount: 50, changes: []}
  end

  defp contain_change?(account, event) do
    assert Enum.member?(account.changes, event)
  end
end
