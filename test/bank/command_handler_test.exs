defmodule Bank.CommandHandlerTest do
  use ExUnit.Case, async: true

  import Mox

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney}
  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawn}

  alias Bank.EventStoreMock

  setup do
    Mox.set_mox_global

    start_supervised {Registry, [keys: :unique, name: Bank.Registry]}
    start_supervised Bank.CommandBus
    start_supervised Bank.CommandHandler
    :ok
  end

  describe "on create account command" do
    test "it does not create an account when it already exists" do
      EventStoreMock
      |> expect(:load_event_stream, fn "Joe" -> {:ok, 0, []} end)
      |> expect_never(:append_to_stream, fn "Joe", _version, _changes -> :ok end)

      :ok = send_command(%CreateAccount{id: "Joe"})

      verify!(EventStoreMock)
    end

    test "it creates an account when not exists" do
      EventStoreMock
      |> expect(:load_event_stream, fn "Joe" -> {:error, :not_found} end)
      |> expect(:append_to_stream, fn "Joe", -1, [%AccountCreated{id: "Joe"}] -> :ok end)

      :ok = send_command(%CreateAccount{id: "Joe"})

      verify!(EventStoreMock)
    end
  end

  describe "on deposit money command" do
    test "an amount is deposited" do
      EventStoreMock
      |> expect(:load_event_stream, fn "Joe" -> {:ok, 0, [%AccountCreated{id: "Joe"}]} end)
      |> expect(:append_to_stream, fn "Joe", 0, [%MoneyDeposited{id: "Joe", amount: 100}] -> :ok end)

      :ok = send_command(%DepositMoney{id: "Joe", amount: 100})

      verify!(EventStoreMock)
    end

    test "nothing is deposited if the account does not exist" do
      EventStoreMock
      |> expect(:load_event_stream, fn "Joe" -> {:error, :not_found} end)
      |> expect_never(:append_to_stream, fn "Joe", 0, [%MoneyDeposited{id: "Joe", amount: 100}] -> :ok end)

      :ok = send_command(%DepositMoney{id: "Joe", amount: 100})

      verify!(EventStoreMock)
    end
  end

  describe "on withdraw money command" do
    test "an amount is withdrawn" do
      EventStoreMock
      |> expect(:load_event_stream, fn "Joe" -> {:ok, 1, [%AccountCreated{id: "Joe"}, %MoneyDeposited{id: "Joe", amount: 100}]} end)
      |> expect(:append_to_stream, fn "Joe", 1, [%MoneyWithdrawn{id: "Joe", amount: 100}] -> :ok end)

      :ok = send_command(%WithdrawMoney{id: "Joe", amount: 100})

      verify!(EventStoreMock)
    end

    test "nothing is withdrawn if the account does not exist" do
      EventStoreMock
      |> expect(:load_event_stream, fn "Joe" -> {:error, :not_found} end)
      |> expect_never(:append_to_stream, fn "Joe", 0, [%MoneyWithdrawn{id: "Joe", amount: 100}] -> :ok end)

      :ok = send_command(%WithdrawMoney{id: "Joe", amount: 100})

      verify!(EventStoreMock)
    end
  end

  test "return an error for unknown commands" do
    assert send_command(:a_not_handled_command) == {:error, :unknown_command}
  end

  defp send_command(command) do
    GenServer.call(:command_handler, command)
  end

  defp expect_never(mock, function_name, function) do
    expect(mock, function_name, 0, function)
  end
end
