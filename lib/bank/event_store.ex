defmodule Bank.EventStore do
  def append_to_stream(_id, _version, _changes), do: {:error, "something wrong"} # {:ok} | {:error, reason}
  def load_event_stream(_id), do: {:error, :not_found} # {:ok, %Bank.EventStream{}} | {:error, reason}
end
