defmodule Bank.EventStore do

  alias Bank.EventStream

  def append_to_stream(_id, _version, _changes), do: {:ok} # {:ok} | {:error, reason}
  def load_event_stream(_id), do: {:ok, %EventStream{}} # | {:error, reason}
end
