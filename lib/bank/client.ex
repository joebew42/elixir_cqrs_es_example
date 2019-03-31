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

  def available_balance(name) do
    find_account!(name).available_balance
  end

  def account_balance(name) do
    find_account!(name).account_balance
  end

  defp find_account!(name) do
    case AccountReadModel.find(name) do
      {:ok, account} ->
        account
      {:error, :not_found} ->
        raise "Account #{inspect(name)} not available"
    end
  end
end