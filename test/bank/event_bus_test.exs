defmodule Bank.EventBusTest do
  use ExUnit.Case, async: true

  alias Bank.EventBus

  defmodule ProxyProcess do
    def start([forward_to: pid]), do: spawn(__MODULE__, :loop, [pid])

    def loop(pid) do
      receive do
        message ->
          send pid, message
          loop(pid)
      end
    end
  end

  test "not subscribed handler do not receive events" do
    EventBus.publish(:an_event)

    refute_receive :an_event
  end

  test "subscribed handler receive events" do
    EventBus.subscribe(self())

    EventBus.publish(:an_event)

    assert_receive {_, :an_event}
  end

  describe "when a subscribed handler dies" do
    test "the event bus will not send events to it" do
      proxy_process = ProxyProcess.start(forward_to: self())
      EventBus.subscribe(proxy_process)
      Process.exit(proxy_process, :kill)

      EventBus.publish(:an_event)

      refute_receive {_, :an_event}
    end
  end
end
