defmodule Bank.CommandHandlerTest do
  use ExUnit.Case, async: true

  import Mock

  alias Bank.Commands.CreateAccount
  alias Bank.Events.AccountCreated
  alias Bank.EventStore

  setup_all do
    {:ok, _pid} = start_supervised Bank.CommandHandler
    :ok
  end

  test "create an account when does not exists" do
    with_mock(EventStore, [append_to_stream: fn(_, _, _) -> {:ok, -1} end]) do
      GenServer.call(:command_handler, %CreateAccount{id: "Joe"})

      assert called EventStore.append_to_stream("Joe", -1, [%AccountCreated{id: "Joe"}])
    end
  end
end