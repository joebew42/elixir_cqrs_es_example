defmodule Bank.Client do

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney, TransferMoney}

  alias Bank.DefaultCommandBus, as: CommandBus
  alias Bank.InMemoryAccountReadModel, as: AccountReadModel

  def create_account(name) do
    account_id = account_id_for(name)

    CommandBus.send(%CreateAccount{account_id: account_id, name: name})
  end

  def deposit(name, amount) do
    account_id = account_id_for(name)

    CommandBus.send(%DepositMoney{account_id: account_id, amount: amount})
  end

  def withdraw(name, amount) do
    account_id = account_id_for(name)

    CommandBus.send(%WithdrawMoney{account_id: account_id, amount: amount})
  end

  def transfer(from, to, amount) do
    from_account_id = account_id_for(from)
    to_account_id = account_id_for(to)

    CommandBus.send(%TransferMoney{account_id: from_account_id, amount: amount, payee: to_account_id, operation_id: UUID.uuid1()})
  end

  def available_balance(name) do
    account_id = account_id_for(name)

    find_account!(account_id).available_balance
  end

  def account_balance(name) do
    account_id = account_id_for(name)

    find_account!(account_id).account_balance
  end

  def status(name) do
    account_id = account_id_for(name)

    find_account!(account_id)
  end

  defp find_account!(account_id) do
    case AccountReadModel.find(account_id) do
      {:ok, account} ->
        account
      {:error, :not_found} ->
        raise "Account #{inspect(account_id)} not available"
    end
  end

  defp account_id_for(name) do
    UUID.uuid5(:nil, name)
  end
end