defmodule Bank.EventBus do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: :event_bus)
  end

  def init(args) do
    {:ok, args}
  end

  def subscribe(subscriber_pid) do
    GenServer.call(:event_bus, subscriber_pid)
  end

  def publish(event) do
    GenServer.cast(:event_bus, {:publish, event})
  end

  def handle_call(subscriber_pid, _pid, subscribers) do
    Process.monitor(subscriber_pid)
    {:reply, :ok, [subscriber_pid | subscribers]}
  end

  def handle_cast({:publish, event}, subscribers) do
    Enum.each(subscribers, fn(subscriber) -> GenServer.cast(subscriber, event) end )
    {:noreply, subscribers}
  end

  def handle_info({:DOWN, _ref, :process, subscriber_pid, _reason}, subscribers) do
    {:noreply, List.delete(subscribers, subscriber_pid)}
  end
end
