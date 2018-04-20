defmodule Bank.CommandHandlerTest do
  use ExUnit.Case, async: true

  import Mock

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney}
  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined}
  alias Bank.{EventStore, EventStream}

  setup_all do
    {:ok, _pid} = start_supervised Bank.CommandHandler
    :ok
  end

  test "create an account when does not exists" do
    with_mock(EventStore, [append_to_stream: fn(_, _, _) -> {:ok, -1} end]) do
      GenServer.call(:command_handler, %CreateAccount{id: "Joe"})

      assert called EventStore.append_to_stream("Joe", -1, [%AccountCreated{id: "Joe"}])
    end
  end

  test "deposit money to an existing account" do
    with_mock EventStore,
      [load_event_stream: fn(_) -> {:ok, %EventStream{version: 0, events: [%AccountCreated{id: "Joe"}]}} end,
       append_to_stream: fn(_, _, _) -> {:ok, 0} end]
    do
      GenServer.call(:command_handler, %DepositMoney{id: "Joe", amount: 100})

      assert called EventStore.append_to_stream("Joe", 0, [%MoneyDeposited{id: "Joe", amount: 100}])
    end
  end

  describe "withdrawn money to an existing amount" do
    test "should decline operation due to insufficient funds" do
      with_mock EventStore,
        [load_event_stream: fn(_) -> {:ok, %EventStream{version: 0, events: [%AccountCreated{id: "Joe"}]}} end,
         append_to_stream: fn(_, _, _) -> {:ok, 0} end]
      do
        GenServer.call(:command_handler, %WithdrawMoney{id: "Joe", amount: 100})

        assert called EventStore.append_to_stream("Joe", 0, [%MoneyWithdrawalDeclined{id: "Joe", amount: 100}])
      end
    end
  end
end