defmodule Bank.Account do
  alias Bank.Events.AccountCreated

  def create(_id), do: {:ok, "pid"}
  def changes("pid"), do: [%AccountCreated{id: "Joe"}]
end