defmodule Bank.ProcessManager do
  @type event() :: struct()
  @type state() :: map()
  @type new_state() :: map()

  @callback handle(event(), state()) :: new_state()
end
