defmodule Bank.InMemoryAccountReadModel do
  @behaviour Bank.AccountReadModel

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl Bank.AccountReadModel
  def update(aggregate_id, amount) do
    GenServer.call(__MODULE__, {:update, aggregate_id, amount})
  end

  @impl Bank.AccountReadModel
  def balance(aggregate_id) do
    GenServer.call(__MODULE__, {:balance, aggregate_id})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:update, aggregate_id, amount}, _from, state) do
    {:reply, :ok, Map.put(state, aggregate_id, amount)}
  end

  @impl true
  def handle_call({:balance, aggregate_id}, _from, state) do
    response = case Map.get(state, aggregate_id, :not_found) do
      :not_found ->
        {:error, :not_found}

      amount ->
        {:ok, amount}
    end

    {:reply, response, state}
  end
end