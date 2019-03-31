defmodule Bank.CommandDispatcherTest do
  use ExUnit.Case, async: false

  import Mox

  defmodule ACommand do
    defstruct [:a_field]
  end

  defmodule AnotherCommand do
    defstruct [:another_field]
  end

  alias Bank.CommandHandlerMock, as: CommandHandler

  setup do
    Mox.set_mox_global

    handlers = %{
      ACommand => CommandHandler
    }

    start_supervised {Task.Supervisor, name: Bank.TaskSupervisor}
    start_supervised {Bank.CommandBus, []}
    start_supervised {Bank.CommandDispatcher, handlers: handlers}

    :ok
  end

  describe "when sending a command" do
    test "it is dispatched to the defined command handler" do
      expect(CommandHandler, :handle, fn(%ACommand{a_field: "something"}) -> :ok end)

      send_command(%ACommand{a_field: "something"})

      verify_mock!(CommandHandler)
    end

    test "nothing is dispatched if no command handler is defined" do
      expect_never(CommandHandler, :handle, fn(%AnotherCommand{another_field: "something"}) -> :ok end)

      send_command(%AnotherCommand{another_field: "something"})

      verify_mock!(CommandHandler)
    end
  end

  defp send_command(command) do
    GenServer.cast(:command_dispatcher, command)
  end

  defp expect_never(mock, name, code) do
    expect(mock, name, 0, code)
  end

  defp verify_mock!(mock, exception \\ nil, retries \\ 3)

  defp verify_mock!(_mock, exception, 0), do: raise exception
  defp verify_mock!(mock, _exception, retries) do
    try do
      verify!(mock)
    rescue
      exception ->
        Process.sleep(20)
        verify_mock!(mock, exception, retries - 1)
    end
  end
end
