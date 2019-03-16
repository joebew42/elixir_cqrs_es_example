defmodule Bank.Client do

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney}
  alias Bank.CommandBus

  alias Bank.InMemoryAccountReadModel, as: AccountReadModel

  def create_account(name) do
    CommandBus.publish(%CreateAccount{id: name})
  end

  def deposit(name, amount) do
    CommandBus.publish(%DepositMoney{id: name, amount: amount})
  end

  def withdraw(name, amount) do
    CommandBus.publish(%WithdrawMoney{id: name, amount: amount})
  end

  def balance(name) do
    Process.sleep(100)
    {:ok, amount} = AccountReadModel.balance(name)
    amount
  end
end