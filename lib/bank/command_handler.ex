defmodule Bank.CommandHandler do
  use GenServer

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney}
  alias Bank.BankService

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: :command_handler)
  end

  def init(nil) do
    Bank.CommandBus.subscribe(self())
    {:ok, nil}
  end

  def handle_call(%CreateAccount{id: name}, _pid, nil) do
    {:reply, BankService.create_account(name), nil}
  end

  def handle_call(%DepositMoney{id: name, amount: amount}, _pid, nil) do
    {:reply, BankService.deposit_money(name, amount), nil}
  end

  def handle_call(%WithdrawMoney{id: name, amount: amount}, _pid, nil) do
    {:reply, BankService.withdraw_money(name, amount), nil}
  end

  def handle_call(_unknown_command, _pid, nil) do
    {:reply, {:error, :unknown_command}, nil}
  end
end
