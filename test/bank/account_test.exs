defmodule Bank.AccountTest do
  use ExUnit.Case, async: true

  alias Bank.EventStream
  alias Bank.Events.AccountCreated
  alias Bank.Account

  test "#new produces an AccountCreated change" do
    {:ok, pid} = Account.new("Joe")

    assert contain_change?(pid, %AccountCreated{id: "Joe"})
  end

  defp contain_change?(pid, event) do
    %EventStream{events: events} = Account.changes(pid)
    assert Enum.member?(events, event)
  end
end
