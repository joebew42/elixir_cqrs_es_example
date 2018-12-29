defmodule Bank.EventStore do
  @type aggregate_id() :: String.t()
  @type version() :: integer()
  @type changes() :: list()

  @type load_result() :: {:ok, version(), changes()} | {:error, :not_found}
  @type append_result() :: :ok | {:error, String.t()}

  @callback load_event_stream(aggregate_id()) :: load_result()
  @callback append_to_stream(aggregate_id(), version(), changes()) :: append_result()
end
