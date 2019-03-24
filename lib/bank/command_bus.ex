defmodule Bank.CommandBus do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: :command_bus)
  end

  def init(args) do
    {:ok, args}
  end

  def subscribe(subscriber_pid) do
    GenServer.call(:command_bus, subscriber_pid)
  end

  def publish(command) do
    GenServer.cast(:command_bus, {:publish, command})
  end

  def handle_call(subscriber_pid, _pid, subscribers) do
    {:reply, :ok, [subscriber_pid | subscribers]}
  end

  def handle_cast({:publish, command}, subscribers) do
    Enum.each(subscribers, fn(subscriber) -> GenServer.cast(subscriber, command) end )

    {:noreply, subscribers}
  end
end
