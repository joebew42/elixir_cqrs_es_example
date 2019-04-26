defmodule Bank.CommandBus do
  @type command() :: struct()
  @type command_handlers() :: map()
  @type result() :: :ok | :nothing

  @callback send(command()) :: result()
  @callback send(command(), command_handlers()) :: result()
end
