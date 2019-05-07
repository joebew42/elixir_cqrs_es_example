defmodule Bank.CommandHandlers.CreateAccountTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.{Events, Commands}

  alias Bank.EventStoreMock, as: EventStore

  alias Bank.CommandHandlers.CreateAccount

  test "it does not create an account when it already exists" do
    EventStore
    |> expect(:load_event_stream, fn "AN ACCOUNT ID" -> {:ok, 0, []} end)
    |> expect_never(:append_to_stream, fn "AN ACCOUNT ID", _version, _changes -> :ok end)

    command =
      %Commands.CreateAccount{
        account_id: "AN ACCOUNT ID",
        name: "AN ACCOUNT NAME"
      }

    :nothing = CreateAccount.handle(command)

    verify!(EventStore)
  end

  test "it creates an account when not exists" do
    EventStore
    |> expect(:load_event_stream, fn "AN ACCOUNT ID" -> {:error, :not_found} end)
    |> expect(:append_to_stream, fn "AN ACCOUNT ID", -1, [%Events.AccountCreated{id: "AN ACCOUNT ID", name: "AN ACCOUNT NAME"}] -> :ok end)

    command =
      %Commands.CreateAccount{
        account_id: "AN ACCOUNT ID",
        name: "AN ACCOUNT NAME"
      }

    :ok = CreateAccount.handle(command)

    verify!(EventStore)
  end

  defp expect_never(mock, function_name, function) do
    expect(mock, function_name, 0, function)
  end
end