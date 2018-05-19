defmodule Bank.BankServiceTest do
  use ExUnit.Case, async: true

  import Mock

  alias Bank.{EventStore, EventStream}
  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined, MoneyWithdrawn}
  alias Bank.AccountRepository

  alias Bank.BankService

  test "does not create an account if it already exist" do
    with_mock AccountRepository, [find_by_id: fn(_) -> {:ok, "Joe"} end] do
      :ok = BankService.create_account("Joe")

      assert called AccountRepository.find_by_id("Joe")
      assert not called AccountRepository.save("Joe")
    end
  end

  test "create an account when it does not exist" do
    with_mock AccountRepository,
      [find_by_id: fn(_) -> {:error, :not_found} end,
       save: fn(_) -> :ok end]
    do
      :ok = BankService.create_account("Joe")

      assert called AccountRepository.find_by_id("Joe")
      assert called AccountRepository.save("Joe")
    end
  end

  test "deposit money to an existing account" do
    with_mock EventStore,
      [load_event_stream: fn(_) -> {:ok, %EventStream{version: 0, events: [%AccountCreated{id: "Joe"}]}} end,
       append_to_stream: fn(_) -> :ok end]
    do
      :ok = BankService.deposit_money("Joe", 100)

      assert called EventStore.append_to_stream(%EventStream{
        id: "Joe", version: 0,
        events: [%MoneyDeposited{id: "Joe", amount: 100}]
      })
    end
  end

  describe "withdrawn money to an existing amount" do
    test "should decline the operation due to insufficient funds" do
      with_mock EventStore,
        [load_event_stream: fn(_) -> {:ok, %EventStream{version: 0, events: [%AccountCreated{id: "Joe"}]}} end,
         append_to_stream: fn(_) -> :ok end]
      do
        :ok = BankService.withdraw_money("Joe", 100)

        assert called EventStore.append_to_stream(%EventStream{
          id: "Joe", version: 0,
          events: [%MoneyWithdrawalDeclined{id: "Joe", amount: 100}]
        })
      end
    end

    test "should accept operation due sufficient funds" do
      with_mock EventStore,
        [load_event_stream: fn(_) -> {:ok, %EventStream{version: 1, events: [%MoneyDeposited{id: "Joe", amount: 100}, %AccountCreated{id: "Joe"}]}} end,
         append_to_stream: fn(_) -> :ok end]
      do
        :ok = BankService.withdraw_money("Joe", 100)

        assert called EventStore.append_to_stream(%EventStream{
          id: "Joe", version: 0,
          events: [%MoneyWithdrawn{id: "Joe", amount: 100}]
        })
      end
    end
  end
end
