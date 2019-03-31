defmodule Bank.AccountReadModel do
  @type account_id() :: String.t()
  @type account_view() :: map()

  @callback save(account_view()) :: :ok
  @callback find(account_id()) :: {:ok, account_view()} | {:error, :not_found}
end
