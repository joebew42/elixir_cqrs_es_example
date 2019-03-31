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
    assert false
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

    Application.start(app)

    :ok = Application.put_env(app, :event_store, Bank.InMemoryEventStore)
    :ok = Application.put_env(app, :event_publisher, Bank.EventBusPublisher)
    :ok = Application.put_env(app, :account_read_model, Bank.InMemoryAccountReadModel)

    on_exit(fn ->
      :ok = Application.put_env(app, :event_store, Bank.EventStoreMock)
      :ok = Application.put_env(app, :event_publisher, Bank.EventPublisherMock)
      :ok = Application.put_env(app, :account_read_model, Bank.AccountReadModelMock)
    end)

    :ok
  end
end
