defmodule Bank.InMemoryAccountReadModel do
  @behaviour Bank.AccountReadModel

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl Bank.AccountReadModel
  def save(account_view) do
    GenServer.call(__MODULE__, {:save, account_view})
  end

  @impl Bank.AccountReadModel
  def find(account_id) do
    GenServer.call(__MODULE__, {:find, account_id})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:save, account_view}, _from, state) do
    {:reply, :ok, Map.put(state, account_view.id, account_view)}
  end

  @impl true
  def handle_call({:find, account_id}, _from, state) do
    response = case Map.get(state, account_id, :not_found) do
      :not_found ->
        {:error, :not_found}

      account_view ->
        {:ok, account_view}
    end

    {:reply, response, state}
  end
end