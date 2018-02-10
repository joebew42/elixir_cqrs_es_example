defmodule Bank.CommandBus do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: :command_bus)
  end

  def subscribe(subscriber_pid) do
    GenServer.call(:command_bus, subscriber_pid)
  end

  def publish(event) do
    GenServer.cast(:command_bus, {:publish, event})
  end

  def handle_call(subscriber_pid, _pid, subscribers) do
    {:reply, :ok, [subscriber_pid | subscribers]}
  end

  def handle_cast({:publish, event}, subscribers) do
    Enum.each(subscribers, fn(subscriber) -> send(subscriber, event) end )
    {:noreply, subscribers}
  end
end
