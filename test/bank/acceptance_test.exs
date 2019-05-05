defmodule Bank.AcceptanceTest do
  use ExUnit.Case

  alias Bank.Client

  @tag :acceptance
  test "As a User I can execute different operations on my account" do
    an_account = "AN_ACCOUNT"

    given_a_new_account(an_account)
    then_the_available_balance_for(an_account, is: 0)

    and_deposit(50, to: an_account)
    and_withdraw(30, from: an_account)
    and_withdraw(100, from: an_account)
    and_deposit(30, to: an_account)

    then_the_available_balance_for(an_account, is: 50)
    then_the_account_balance_for(an_account, is: 50)
  end

  @tag :acceptance
  test "As a User I can transfer money to another account" do
    an_account = "AN_ACCOUNT"
    another_account = "ANOTHER_ACCOUNT"

    given_a_new_account(an_account)
    given_a_new_account(another_account)

    and_deposit(100, to: an_account)
    and_deposit(100, to: another_account)

    and_transfer(50, from: an_account, to: another_account)

    then_the_account_balance_for(an_account, is: 50)
    then_the_available_balance_for(an_account, is: 50)

    then_the_account_balance_for(another_account, is: 150)
    then_the_available_balance_for(another_account, is: 150)
  end

  defp given_a_new_account(account) do
    assert Client.create_account(account) == :ok
  end

  defp and_deposit(amount, to: account) do
    assert Client.deposit(account, amount) == :ok
  end

  defp and_withdraw(amount, from: account) do
    assert Client.withdraw(account, amount) == :ok
  end

  defp and_transfer(amount, from: from, to: to) do
    assert Client.transfer(from, to, amount)
  end

  defp then_the_available_balance_for(account, is: amount) do
    Process.sleep(10)
    assert Client.available_balance(account) == amount
  end

  defp then_the_account_balance_for(account, is: amount) do
    Process.sleep(10)
    assert Client.account_balance(account) == amount
  end

  setup %{acceptance: true} do
    app = :elixir_cqrs_es_example

    Application.stop(app)
    Application.start(app)

    :ok = Application.put_env(app, :command_bus, Bank.DefaultCommandBus)
    :ok = Application.put_env(app, :event_store, Bank.InMemoryEventStore)
    :ok = Application.put_env(app, :event_publisher, Bank.EventBusPublisher)
    :ok = Application.put_env(app, :account_read_model, Bank.InMemoryAccountReadModel)
    :ok = Application.put_env(app, :transfer_operation_process_manager, Bank.TransferOperationProcessManager)

    on_exit(fn ->
      :ok = Application.put_env(app, :command_bus, Bank.CommandBusMock)
      :ok = Application.put_env(app, :event_store, Bank.EventStoreMock)
      :ok = Application.put_env(app, :event_publisher, Bank.EventPublisherMock)
      :ok = Application.put_env(app, :account_read_model, Bank.AccountReadModelMock)
      :ok = Application.put_env(app, :transfer_operation_process_manager, Bank.ProcessManagerMock)
    end)

    :ok
  end
end
