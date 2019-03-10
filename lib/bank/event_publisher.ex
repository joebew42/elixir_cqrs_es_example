defmodule Bank.EventPublisher do
  @type event() :: struct()

  @callback publish(event()) :: :ok
end
