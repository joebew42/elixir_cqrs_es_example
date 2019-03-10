defmodule Bank.EventBusPublisher do
  @behaviour Bank.EventPublisher

  alias Bank.EventBus

  @impl Bank.EventPublisher
  def publish(an_event) do
    EventBus.publish(an_event)
    :ok
  end
end