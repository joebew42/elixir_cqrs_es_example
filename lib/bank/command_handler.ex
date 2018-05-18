defmodule Bank.CommandHandler do
  use GenServer

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney}
  alias Bank.EventStore
  alias Bank.{Accounts, Account}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: :command_handler)
  end

  def init(nil) do
    {:ok, nil}
  end

  def handle_call(%CreateAccount{id: name}, _pid, nil) do
    {:reply, Accounts.create_account(name), nil}
  end

  def handle_call(%DepositMoney{id: name, amount: amount}, _pid, nil) do
    {:reply, Accounts.deposit_money(name, amount), nil}
  end

  def handle_call(%WithdrawMoney{id: name, amount: amount}, _pid, nil) do
    {:reply, Accounts.withdraw_money(name, amount), nil}
  end
end