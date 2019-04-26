defmodule Bank.CommandBusTest do
  use ExUnit.Case, async: true

  import Mox

  defmodule ACommand do
    defstruct [:a_field]
  end

  defmodule AnotherCommand do
    defstruct [:another_field]
  end

  alias Bank.CommandHandlerMock, as: CommandHandler

  alias Bank.CommandBus

  setup do
    %{handlers: %{
      ACommand => CommandHandler
    }}
  end

  test "when a handler is defined the command is handled", %{handlers: handlers} do
    expect(CommandHandler, :handle, fn(%ACommand{a_field: "something"}) -> :ok end)

    CommandBus.send(%ACommand{a_field: "something"}, handlers)

    verify!(CommandHandler)
  end

  test "when no handler is defined the command is not handled", %{handlers: handlers} do
    expect_never(CommandHandler, :handle, fn(%AnotherCommand{another_field: "something"}) -> :ok end)

    CommandBus.send(%AnotherCommand{another_field: "something"}, handlers)

    verify!(CommandHandler)
  end

  defp expect_never(mock, name, code) do
    expect(mock, name, 0, code)
  end
end
