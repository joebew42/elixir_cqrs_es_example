defmodule Bank.EventStore do
  def append_to_stream(_id, _version, _changes), do: {:ok, -1} # | {:error, reason}
end
