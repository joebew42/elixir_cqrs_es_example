defmodule Bank.EventStore do
  @type aggregate_id() :: String.t()
  @type version() :: integer()
  @type changes() :: list()

  @callback load_event_stream(aggregate_id()) :: {:ok, version(), changes()} | {:error, :not_found}
  @callback append_to_stream(aggregate_id(), version(), changes()) :: :ok | {:error, String.t()}
end
