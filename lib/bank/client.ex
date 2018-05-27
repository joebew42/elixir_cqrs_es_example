defmodule Bank.Client do

  alias Bank.Events.AccountCreated
  alias Bank.Commands.CreateAccount
  alias Bank.CommandBus

  def create_account(name) do
    CommandBus.publish(%CreateAccount{id: name})

    wait_until_receive(%AccountCreated{id: name})

    :ok
  end

  def balance(_name) do
    0 # there should be a view
  end

  defp wait_until_receive(_event) do
    # receive do
    #  event -> :ok
    # end
  end
end