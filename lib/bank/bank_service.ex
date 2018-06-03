defmodule Bank.BankService do

  alias Bank.{AccountRepository, Account}

  def create_account(id) do
    case AccountRepository.find_by_id(id) do
      {:ok, ^id} ->
        :ok
      {:error, :not_found} ->
        {:ok, ^id} = Account.new(id)
        AccountRepository.save(id)
        :ok
    end
  end

  def deposit_money(id, amount) do
    case AccountRepository.find_by_id(id) do
      {:ok, ^id} ->
        Account.deposit(id, amount)
        AccountRepository.save(id)
    end
  end

  def withdraw_money(id, amount) do
    case AccountRepository.find_by_id(id) do
      {:ok, ^id} ->
        Account.deposit(id, amount)
        AccountRepository.save(id)
    end
  end
end
