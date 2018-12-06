defmodule Bank.AcceptanceTest do
  use ExUnit.Case, async: true

  alias Bank.Client

  @tag :ignore
  test "As a User I can create a new account" do
    when_create_a_new_account()
    then_the_balance_is_zero()
  end

  defp when_create_a_new_account() do
    assert Client.create_account("AN_ACCOUNT") == :ok
  end

  defp then_the_balance_is_zero() do
    assert Client.balance("AN_ACCOUNT") == 0
  end
end
