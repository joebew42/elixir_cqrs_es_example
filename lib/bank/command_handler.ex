defmodule Bank.CommandHandler do
  @type command() :: struct()
  @type result() :: :ok | :nothing

  @callback handle(command()) :: result()
end
