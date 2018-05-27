defmodule Bank.UATTest do
  use ExUnit.Case, async: true

  alias Bank.Client

  describe "as a user I can create an account" do
    test "so that I can check my balance" do
      :ok = Client.create_account("Joe")

      assert Client.balance("Joe") == 0
    end
  end
end