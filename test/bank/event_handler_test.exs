defmodule Bank.EventHandlerTest do
  use ExUnit.Case

  import Mox

  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawn}

  alias Bank.AccountReadModelMock, as: AccountReadModel

  setup do
    Mox.set_mox_global

    start_supervised Bank.EventBus
    start_supervised Bank.EventHandler

    stub(AccountReadModel, :balance, fn(_id) -> {:ok, 0} end)
    :ok
  end

  test "Initialize the account on AccountCreated event" do
    expect(AccountReadModel, :update, fn "Joe", 0 -> :ok end)

    publish(%AccountCreated{id: "Joe"})

    verify!(AccountReadModel)
  end

  test "Update the balance on MoneyDeposited event" do
    expect(AccountReadModel, :update, fn "Joe", 10 -> :ok end)

    publish(%MoneyDeposited{id: "Joe", amount: 10})

    verify!(AccountReadModel)
  end

  test "Update the balance on MoneyWithdrawn event" do
    expect(AccountReadModel, :update, fn "Joe", -10 -> :ok end)

    publish(%MoneyWithdrawn{id: "Joe", amount: 10})

    verify!(AccountReadModel)
  end

  defp publish(event) do
    GenServer.cast(:event_handler, event)
    Process.sleep(200)
  end
end