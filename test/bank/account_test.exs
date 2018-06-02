defmodule Bank.AccountTest do
  use ExUnit.Case, async: true

  alias Bank.EventStream
  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined, MoneyWithdrawn}
  alias Bank.Account

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

  test "#load_from_event_stream load the state from an EventStream" do
    event_stream = %EventStream{
      id: "Joe", version: 1,
      events: [
        %MoneyDeposited{id: "Joe", amount: 100},
        %AccountCreated{id: "Joe"},
      ]
    }

    {:ok, id} = Account.load_from_event_stream(event_stream)

    assert has_version?(id, 1)
  end

  defp contain_change?(id, event) do
    %EventStream{events: events} = Account.changes(id)
    assert Enum.member?(events, event)
  end

  defp has_version?(id, version) do
    assert %EventStream{id: ^id, version: ^version} = Account.changes(id)
  end
end
