defmodule Bank.ProcessManager do
  @type event() :: struct()
  @type state() :: map()
  @type new_state() :: map()

  @callback on(event(), state()) :: new_state()
end
