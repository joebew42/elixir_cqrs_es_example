defmodule Bank.CommandHandlers.CreateAccountTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.{Events, Commands}

  alias Bank.EventStoreMock, as: EventStore

  alias Bank.CommandHandlers.CreateAccount

  test "it does not create an account when it already exists" do
    EventStore
    |> expect(:load_event_stream, fn "Joe" -> {:ok, 0, []} end)
    |> expect_never(:append_to_stream, fn "Joe", _version, _changes -> :ok end)

    :nothing = CreateAccount.handle(%Commands.CreateAccount{id: "Joe"})

    verify!(EventStore)
  end

  test "it creates an account when not exists" do
    EventStore
    |> expect(:load_event_stream, fn "Joe" -> {:error, :not_found} end)
    |> expect(:append_to_stream, fn "Joe", -1, [%Events.AccountCreated{id: "Joe"}] -> :ok end)

    :ok = CreateAccount.handle(%Commands.CreateAccount{id: "Joe"})

    verify!(EventStore)
  end

  defp expect_never(mock, function_name, function) do
    expect(mock, function_name, 0, function)
  end
end