defmodule Bank.BankService do

  alias Bank.{AccountRepository, Account}

  def create_account(name) do
    case AccountRepository.find_by_id(name) do
      {:ok, _pid} ->
        :ok
      {:error, :not_found} ->
        # {:ok, _pid} = Account.new(name) # how to document this collaboration with a test?
        AccountRepository.save(name)
        :ok
    end
  end

  def deposit_money(name, _amount) do
    case AccountRepository.find_by_id(name) do
      {:ok, _pid} ->
        # Account.deposit(pid, amount) # how to document this collaboration with a test?
        AccountRepository.save(name)
    end
  end

  def withdraw_money(name, _amount) do
    case AccountRepository.find_by_id(name) do
      {:ok, _pid} ->
        # Account.deposit(pid, amount) # how to document this collaboration with a test?
        AccountRepository.save(name)
    end
  end
end
