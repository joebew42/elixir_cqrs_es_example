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
    account_read_model().save(%{
      id: id,
      available_balance: 0,
      account_balance: 0
    })

    {:noreply, state}
  end

  def handle_cast(%MoneyDeposited{id: id, amount: amount}, state) do
    {:ok, account_view} = account_read_model().find(id)

    updated_account_view =
      account_view
      |> Map.put(:available_balance, account_view.available_balance + amount)
      |> Map.put(:account_balance, account_view.account_balance + amount)

    account_read_model().save(updated_account_view)

    {:noreply, state}
  end

  def handle_cast(%MoneyWithdrawn{id: id, amount: amount}, state) do
    {:ok, account_view} = account_read_model().find(id)

    updated_account_view =
      account_view
      |> Map.put(:available_balance, account_view.available_balance - amount)
      |> Map.put(:account_balance, account_view.account_balance - amount)

    account_read_model().save(updated_account_view)

    {:noreply, state}
  end

  def handle_cast(_unhandled_event, state) do
    {:noreply, state}
  end

  defp account_read_model() do
    Application.get_env(:elixir_cqrs_es_example, :account_read_model)
  end
end
