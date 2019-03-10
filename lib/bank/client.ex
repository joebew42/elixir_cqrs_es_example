defmodule Bank.Client do

  alias Bank.Events.AccountCreated
  alias Bank.Commands.CreateAccount
  alias Bank.{CommandBus, EventBus}

  def create_account(name) do
    EventBus.subscribe(self())
    CommandBus.publish(%CreateAccount{id: name})

    :ok = wait_until_receive(%AccountCreated{id: name})
  end

  def balance(_name) do
    0 # there should be a view / a read model
  end

  defp wait_until_receive(event) do
    receive do
      event -> :ok
    after
      2_000 -> {:error, {:not_received, event}}
    end
  end
end