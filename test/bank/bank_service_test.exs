defmodule Bank.BankServiceTest do
  use ExUnit.Case, async: true

  import Mock

  alias Bank.AccountRepository

  alias Bank.BankService

  test "does not create an account if it already exist" do
    with_mock AccountRepository, [find_by_id: fn(_) -> {:ok, "Joe"} end] do
      :ok = BankService.create_account("Joe")

      assert called AccountRepository.find_by_id("Joe")
      assert not called AccountRepository.save("Joe")
    end
  end

  test "create an account when it does not exist" do
    with_mock AccountRepository,
      [find_by_id: fn(_) -> {:error, :not_found} end,
       save: fn(_) -> :ok end]
    do
      :ok = BankService.create_account("Joe")

      assert called AccountRepository.find_by_id("Joe")
      assert called AccountRepository.save("Joe")
    end
  end

  test "deposit money to an existing account" do
    with_mock AccountRepository,
      [find_by_id: fn(_) -> {:ok, "Joe"} end,
       save: fn(_) -> :ok end]
    do
      :ok = BankService.deposit_money("Joe", 100)

      assert called AccountRepository.find_by_id("Joe")
      assert called AccountRepository.save("Joe")
    end
  end

  test "withdraw money from an existing account" do
    with_mock AccountRepository,
      [find_by_id: fn(_) -> {:ok, "Joe"} end,
       save: fn(_) -> :ok end]
    do
      :ok = BankService.withdraw_money("Joe", 100)

      assert called AccountRepository.find_by_id("Joe")
      assert called AccountRepository.save("Joe")
    end
  end
end
