defmodule Bank.CommandHandlerTest do
  use ExUnit.Case, async: true

  import Mock

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney}
  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined, MoneyWithdrawn}
  alias Bank.{EventStore, EventStream}

  setup_all do
    {:ok, _pid} = start_supervised Bank.CommandHandler
    :ok
  end

  test "create an account when it does not exist" do
    with_mock EventStore,
     [load_event_stream: fn(_) -> {:error, :not_found} end,
      append_to_stream: fn(_, _, _) -> {:ok} end]
    do
      send_command(%CreateAccount{id: "Joe"})

      assert called EventStore.append_to_stream("Joe", -1, [%AccountCreated{id: "Joe"}])
    end
  end

  test "does not create an account when it already exists" do
    send_command(%CreateAccount{id: "Joe"})

    with_mock EventStore,
      [load_event_stream: fn(_) -> {:ok, %EventStream{version: 0, events: [%AccountCreated{id: "Joe"}]}} end,
       append_to_stream: fn(_, _, _) -> {:ok} end]
    do
      send_command(%CreateAccount{id: "Joe"})

      assert called EventStore.load_event_stream("Joe")
      assert not called EventStore.append_to_stream("Joe", -1, [%AccountCreated{id: "Joe"}])
    end
  end

  test "deposit money to an existing account" do
    with_mock EventStore,
      [load_event_stream: fn(_) -> {:ok, %EventStream{version: 0, events: [%AccountCreated{id: "Joe"}]}} end,
       append_to_stream: fn(_, _, _) -> {:ok} end]
    do
      send_command(%DepositMoney{id: "Joe", amount: 100})

      assert called EventStore.append_to_stream("Joe", 0, [%MoneyDeposited{id: "Joe", amount: 100}])
    end
  end

  describe "withdrawn money to an existing amount" do
    test "should decline operation due to insufficient funds" do
      with_mock EventStore,
        [load_event_stream: fn(_) -> {:ok, %EventStream{version: 0, events: [%AccountCreated{id: "Joe"}]}} end,
         append_to_stream: fn(_, _, _) -> {:ok} end]
      do
        send_command(%WithdrawMoney{id: "Joe", amount: 100})

        assert called EventStore.append_to_stream("Joe", 0, [%MoneyWithdrawalDeclined{id: "Joe", amount: 100}])
      end
    end

    test "should accept operation due sufficient funds" do
      with_mock EventStore,
        [load_event_stream: fn(_) -> {:ok, %EventStream{version: 1, events: [%MoneyDeposited{id: "Joe", amount: 100}, %AccountCreated{id: "Joe"}]}} end,
         append_to_stream: fn(_, _, _) -> {:ok} end]
      do
        send_command(%WithdrawMoney{id: "Joe", amount: 100})

        assert called EventStore.append_to_stream("Joe", 1, [%MoneyWithdrawn{id: "Joe", amount: 100}])
      end
    end
  end

  defp send_command(command), do: GenServer.call(:command_handler, command)
end