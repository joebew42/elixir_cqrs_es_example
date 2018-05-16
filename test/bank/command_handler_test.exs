defmodule Bank.CommandHandlerTest do
  use ExUnit.Case, async: true

  import Mock

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney}
  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined, MoneyWithdrawn}
  alias Bank.{EventStore, EventStream, Accounts}

  setup_all do
    {:ok, _pid} = start_supervised Bank.CommandHandler
    :ok
  end

  describe "on create account command" do
    test "an account is created" do
      with_mock Accounts, [create_account: fn(_) -> :ok end] do
        send_command(%CreateAccount{id: "Joe"})

        assert called Accounts.create_account("Joe")
      end
    end
  end

  test "deposit money to an account" do
    with_mock Accounts, [deposit_money: fn(_, _) -> :ok end] do
      send_command(%DepositMoney{id: "Joe", amount: 100})

      assert called Accounts.deposit_money("Joe", 100)
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