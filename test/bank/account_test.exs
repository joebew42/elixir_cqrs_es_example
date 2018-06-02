defmodule Bank.AccountTest do
  use ExUnit.Case, async: true

  alias Bank.EventStream
  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined, MoneyWithdrawn}
  alias Bank.Account

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

  describe "#withdraw" do
    test "produces a MoneyWithdrawalDeclined if there is no sufficient funds", %{id: id} do
      Account.withdraw(id, 100)

      assert contain_change?(id, %MoneyWithdrawalDeclined{id: "Joe", amount: 100})
    end

    test "produces a MoneyWithdrawn", %{id: id} do
      Account.deposit(id, 100)
      Account.withdraw(id, 100)

      assert contain_change?(id, %MoneyWithdrawn{id: "Joe", amount: 100})
    end
  end

  defp contain_change?(id, event) do
    %EventStream{events: events} = Account.changes(id)
    assert Enum.member?(events, event)
  end
end
