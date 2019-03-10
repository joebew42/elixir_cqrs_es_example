defmodule Bank.AcceptanceTest do
  use ExUnit.Case

  alias Bank.Client

  @tag :acceptance
  test "As a User I can create a new account" do
    when_create_a_new_account()
    then_the_balance_is_zero()
  end

  defp when_create_a_new_account() do
    assert Client.create_account("AN_ACCOUNT") == :ok
  end

  defp then_the_balance_is_zero() do
    assert Client.balance("AN_ACCOUNT") == 0
  end

  setup %{acceptance: true} do
    app = :elixir_cqrs_es_example

    :ok = Application.start(app)

    :ok = Application.put_env(app, :event_store, Bank.InMemoryEventStore)
    :ok = Application.put_env(app, :event_publisher, Bank.EventBusPublisher)

    on_exit(fn ->
      :ok = Application.put_env(app, :event_store, Bank.EventStoreMock)
      :ok = Application.put_env(app, :event_publisher, Bank.EventPublisherMock)
    end)

    :ok
  end
end
