defmodule Bank.EventHandlerTest do
  use ExUnit.Case

  import Mox

  alias Bank.Events

  alias Bank.AccountReadModelMock, as: AccountReadModel

  setup do
    Mox.set_mox_global

    start_supervised Bank.EventBus
    start_supervised Bank.EventHandler

    :ok
  end

  test "Initialize the account on AccountCreated event" do
    expect(AccountReadModel, :save, fn %{id: "AN ID", name: "A NAME", available_balance: 0, account_balance: 0} -> :ok end)

    publish(%Events.AccountCreated{id: "AN ID", name: "A NAME"})

    verify!(AccountReadModel)
  end

  test "Update the balance on MoneyDeposited event" do
    AccountReadModel
    |> expect(:find, fn("AN ID") -> {:ok, %{id: "AN ID", available_balance: 0, account_balance: 0}} end)
    |> expect(:save, fn %{id: "AN ID", available_balance: 10, account_balance: 10} -> :ok end)

    publish(%Events.MoneyDeposited{id: "AN ID", amount: 10})

    verify!(AccountReadModel)
  end

  test "Update the balance on MoneyWithdrawn event" do
    AccountReadModel
    |> expect(:find, fn("AN ID") -> {:ok, %{id: "AN ID", available_balance: 10, account_balance: 10}} end)
    |> expect(:save, fn %{id: "AN ID", available_balance: 0, account_balance: 0} -> :ok end)

    publish(%Events.MoneyWithdrawn{id: "AN ID", amount: 10})

    verify!(AccountReadModel)
  end

  test "Update the balance on TransferOperationOpened event" do
    AccountReadModel
    |> expect(:find, fn("AN ID") -> {:ok, %{id: "AN ID", available_balance: 10, account_balance: 10}} end)
    |> expect(:save, fn %{id: "AN ID", available_balance: 10, account_balance: 0} -> :ok end)

    publish(%Events.TransferOperationOpened{id: "AN ID", amount: 10, payee: "Someone", operation_id: "an operation id"})

    verify!(AccountReadModel)
  end

  test "Update the balance on TransferOperationConfirmed event" do
    AccountReadModel
    |> expect(:find, fn("AN ID") -> {:ok, %{id: "AN ID", available_balance: 0, account_balance: 0}} end)
    |> expect(:save, fn %{id: "AN ID", available_balance: 10, account_balance: 10} -> :ok end)

    publish(%Events.TransferOperationConfirmed{id: "AN ID", amount: 10, payer: "Someone", operation_id: "an operation id"})

    verify!(AccountReadModel)
  end

  test "Update the balance on TransferOperationCompleted event" do
    AccountReadModel
    |> expect(:find, fn("AN ID") -> {:ok, %{id: "AN ID", available_balance: 100, account_balance: 50}} end)
    |> expect(:save, fn %{id: "AN ID", available_balance: 50, account_balance: 50} -> :ok end)

    publish(%Events.TransferOperationCompleted{id: "AN ID", amount: 50, payee: "Someone", operation_id: "an operation id"})

    verify!(AccountReadModel)
  end

  defp publish(event) do
    Bank.EventBus.publish(event)
    Process.sleep(10)
  end
end