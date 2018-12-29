defmodule Bank.AccountTest do
  use ExUnit.Case, async: true

  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined, MoneyWithdrawn}
  alias Bank.Account

  setup do
    start_supervised {Registry, keys: :unique, name: Bank.Registry}
    :ok
  end

  describe "with a new account" do
    setup do
      {:ok, id} = Account.new("Joe")
      %{id: id}
    end

    test "#new produces an AccountCreated change", %{id: id} do
      assert contain_change?(id, %AccountCreated{id: "Joe"})
    end

    test "#deposit produces a MoneyDeposited change", %{id: id} do
      Account.deposit(id, 100)

      assert contain_change?(id, %MoneyDeposited{id: "Joe", amount: 100})
    end

    test "#withdraw produces a MoneyWithdrawalDeclined if there is no sufficient funds", %{id: id} do
      Account.withdraw(id, 100)

      assert contain_change?(id, %MoneyWithdrawalDeclined{id: "Joe", amount: 100})
    end

    test "#withdraw produces a MoneyWithdrawn", %{id: id} do
      Account.deposit(id, 100)
      Account.withdraw(id, 100)

      assert contain_change?(id, %MoneyWithdrawn{id: "Joe", amount: 100})
    end
  end

  test "#load_from_event_stream load the state from events" do
    changes = [
      %MoneyDeposited{id: "Joe", amount: 100},
      %AccountCreated{id: "Joe"},
    ]

    assert Account.load_from_event_stream("Joe", changes) == {:ok, "Joe"}
  end

  describe "#exists?" do
    test "return false when the account does not exist" do
      assert Account.exists?("unexisting_account") == false
    end

    test "return true when the account exists" do
      Account.new("Joe")

      assert Account.exists?("Joe")
    end
  end

  defp contain_change?(id, event) do
    assert Enum.member?(Account.changes(id), event)
  end
end
