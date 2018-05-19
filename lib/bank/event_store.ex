defmodule Bank.EventStore do
  alias Bank.EventStream

  def append_to_stream(_changes = %EventStream{}), do: :ok
  def load_event_stream(_id), do: {:error, :not_found} # {:ok, %Bank.EventStream{}} | {:error, reason}
end
