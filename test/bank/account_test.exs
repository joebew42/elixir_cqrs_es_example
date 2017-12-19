defmodule Bank.AccountTest do
  use ExUnit.Case

  test "creates a new account" do
    {:ok, pid} = Bank.Account.start

    Bank.Account.create(pid, "Joe")

    assert Bank.Account.id(pid) == "Joe"
  end
end
