defmodule Bank.CommandDispatcherTest do
  use ExUnit.Case, async: true

  setup do
    start_supervised Bank.CommandBus
    start_supervised Bank.CommandDispatcher
    :ok
  end

  describe "on create account command" do
    test "what?" do

    end
  end

  describe "on deposit money command" do
    test "what?" do

    end
  end

  describe "on withdraw money command" do
    test "what?" do

    end
  end

  defp send_command(command) do
    GenServer.cast(:command_handler, command)
  end
end
