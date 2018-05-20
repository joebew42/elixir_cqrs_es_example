defmodule Bank.AccountTest do
  use ExUnit.Case, async: true

  alias Bank.EventStream
  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined, MoneyWithdrawn}
  alias Bank.Account

  setup do
    {:ok, pid} = Account.new("Joe")
    %{pid: pid}
  end

  test "#new produces an AccountCreated change", %{pid: pid} do
    assert contain_change?(pid, %AccountCreated{id: "Joe"})
  end

  test "#deposit produces a MoneyDeposited change", %{pid: pid} do
    Account.deposit(pid, 100)

    assert contain_change?(pid, %MoneyDeposited{id: "Joe", amount: 100})
  end

  describe "#withdraw" do
    test "produces a MoneyWithdrawalDeclined if there is no sufficient funds", %{pid: pid} do
      Account.withdraw(pid, 100)

      assert contain_change?(pid, %MoneyWithdrawalDeclined{id: "Joe", amount: 100})
    end

    test "produces a MoneyWithdrawn", %{pid: pid} do
      Account.deposit(pid, 100)
      Account.withdraw(pid, 100)

      assert contain_change?(pid, %MoneyWithdrawn{id: "Joe", amount: 100})
    end
  end

  defp contain_change?(pid, event) do
    %EventStream{events: events} = Account.changes(pid)
    assert Enum.member?(events, event)
  end
end
