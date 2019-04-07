defmodule Bank.EventHandlerTest do
  use ExUnit.Case

  import Mox

  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawn,
                    TransferOperationOpened}

  alias Bank.AccountReadModelMock, as: AccountReadModel

  setup do
    Mox.set_mox_global

    start_supervised Bank.EventBus
    start_supervised Bank.EventHandler

    :ok
  end

  test "Initialize the account on AccountCreated event" do
    expect(AccountReadModel, :save, fn %{id: "Joe", available_balance: 0, account_balance: 0} -> :ok end)

    publish(%AccountCreated{id: "Joe"})

    verify!(AccountReadModel)
  end

  test "Update the balance on MoneyDeposited event" do
    AccountReadModel
    |> expect(:find, fn("Joe") -> {:ok, %{id: "Joe", available_balance: 0, account_balance: 0}} end)
    |> expect(:save, fn %{id: "Joe", available_balance: 10, account_balance: 10} -> :ok end)

    publish(%MoneyDeposited{id: "Joe", amount: 10})

    verify!(AccountReadModel)
  end

  test "Update the balance on MoneyWithdrawn event" do
    AccountReadModel
    |> expect(:find, fn("Joe") -> {:ok, %{id: "Joe", available_balance: 10, account_balance: 10}} end)
    |> expect(:save, fn %{id: "Joe", available_balance: 0, account_balance: 0} -> :ok end)

    publish(%MoneyWithdrawn{id: "Joe", amount: 10})

    verify!(AccountReadModel)
  end

  test "Update the balance on TransferOperationOpened event" do
    AccountReadModel
    |> expect(:find, fn("Joe") -> {:ok, %{id: "Joe", available_balance: 10, account_balance: 10}} end)
    |> expect(:save, fn %{id: "Joe", available_balance: 10, account_balance: 0} -> :ok end)

    publish(%TransferOperationOpened{id: "Joe", amount: 10, payee: "Someone", operation_id: "an operation id"})

    verify!(AccountReadModel)
  end

  defp publish(event) do
    GenServer.cast(:event_handler, event)
    Process.sleep(10)
  end
end