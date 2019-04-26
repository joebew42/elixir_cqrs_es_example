defmodule Bank.Client do

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney, TransferMoney}

  alias Bank.DefaultCommandBus, as: CommandBus
  alias Bank.InMemoryAccountReadModel, as: AccountReadModel

  def create_account(name) do
    CommandBus.send(%CreateAccount{id: name})
  end

  def deposit(name, amount) do
    CommandBus.send(%DepositMoney{id: name, amount: amount})
  end

  def withdraw(name, amount) do
    CommandBus.send(%WithdrawMoney{id: name, amount: amount})
  end

  def transfer(from, to, amount) do
    CommandBus.send(%TransferMoney{id: from, amount: amount, payee: to, operation_id: UUID.uuid1()})
  end

  def available_balance(name) do
    find_account!(name).available_balance
  end

  def account_balance(name) do
    find_account!(name).account_balance
  end

  def status(name) do
    find_account!(name)
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