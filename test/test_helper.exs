ExUnit.start(trace: true)

defmodule TestableCommandHandler do
  use GenServer

  @max_number_of_retries 5

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: :testable_command_handler)
  end

  def init(messages) do
    {:ok, messages}
  end

  def received?(message), do: do_received?(message, @max_number_of_retries)

  def handle_call({:received?, message}, _from, messages) do
    {:reply, Enum.member?(messages, message), messages}
  end

  def handle_call(message, _from, messages) do
    {:reply, :ok, [message|messages]}
  end

  defp do_received?(_message, _retries = 0), do: false
  defp do_received?(message, retries) do
    case GenServer.call(:testable_command_handler, {:received?, message}) do
      true -> true
      false -> do_received?(message, retries - 1)
    end
  end
end