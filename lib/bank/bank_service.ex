defmodule Bank.BankService do

  alias Bank.{AccountRepository, Account}

  def create_account(id) do
    case AccountRepository.find_by_id(id) do
      {:ok, _id} ->
        :ok
      {:error, :not_found} ->
        # {:ok, _pid} = Account.new(id) # how to document this collaboration with a test?
        AccountRepository.save(id)
        :ok
    end
  end

  def deposit_money(id, _amount) do
    case AccountRepository.find_by_id(id) do
      {:ok, _id} ->
        # Account.deposit(pid, amount) # how to document this collaboration with a test?
        AccountRepository.save(id)
    end
  end

  def withdraw_money(id, _amount) do
    case AccountRepository.find_by_id(id) do
      {:ok, _id} ->
        # Account.deposit(pid, amount) # how to document this collaboration with a test?
        AccountRepository.save(id)
    end
  end
end
