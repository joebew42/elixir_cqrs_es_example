defmodule Bank.AcceptanceTest do
  use ExUnit.Case

  alias Bank.Client

  @tag :acceptance
  test "As a User I can run several operations on my account" do
    when_create_a_new_account()
    then_the_balance_is(0)
    and_deposit(50)
    then_the_balance_is(50)
    and_withdraw(30)
    then_the_balance_is(20)
    and_withdraw(100)
    then_the_balance_is(20)
  end

  defp when_create_a_new_account() do
    assert Client.create_account("AN_ACCOUNT") == :ok
  end

  defp and_deposit(amount) do
    assert Client.deposit("AN_ACCOUNT", amount) == :ok
  end

  defp and_withdraw(amount) do
    assert Client.withdraw("AN_ACCOUNT", amount) == :ok
  end

  defp then_the_balance_is(amount) do
    assert Client.balance("AN_ACCOUNT") == amount
  end

  setup %{acceptance: true} do
    app = :elixir_cqrs_es_example

    :ok = Application.start(app)

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
