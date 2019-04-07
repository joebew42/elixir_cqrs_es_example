defmodule Bank.Commands do
  defmodule CreateAccount do
    defstruct [:id]
  end

  defmodule DepositMoney do
    defstruct [:id, :amount]
  end

  defmodule WithdrawMoney do
    defstruct [:id, :amount]
  end

  defmodule TransferMoney do
    defstruct [:id, :amount, :payee, :operation_id]
  end
end