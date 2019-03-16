defmodule Bank.AccountReadModel do
  @type aggregate_id() :: String.t()
  @type amount() :: integer()
  @type balance() :: integer()

  @callback update(aggregate_id(), amount()) :: :ok
  @callback balance(aggregate_id()) :: {:ok, balance()} | {:error, :not_found}
end
