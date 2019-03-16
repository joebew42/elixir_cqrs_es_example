defmodule Bank.EventHandler do
  use GenServer

  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawn}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: :event_handler)
  end

  def init(nil) do
    Bank.EventBus.subscribe(self())
    {:ok, nil}
  end

  def handle_cast(%AccountCreated{id: id}, state) do
    account_read_model().update(id, 0)

    {:noreply, state}
  end

  def handle_cast(%MoneyDeposited{id: id, amount: amount}, state) do
    {:ok, current_balance} = account_read_model().balance(id)
    account_read_model().update(id, current_balance + amount)

    {:noreply, state}
  end

  def handle_cast(%MoneyWithdrawn{id: id, amount: amount}, state) do
    {:ok, current_balance} = account_read_model().balance(id)
    account_read_model().update(id, current_balance - amount)

    {:noreply, state}
  end

  def handle_cast(_unhandled_event, state) do
    {:noreply, state}
  end

  defp account_read_model() do
    Application.get_env(:elixir_cqrs_es_example, :account_read_model)
  end
end
