defmodule Bank.Commands do
  defmodule CreateAccount do
    defstruct [:account_id, :name]
  end

  defmodule DepositMoney do
    defstruct [:account_id, :amount]
  end

  defmodule WithdrawMoney do
    defstruct [:account_id, :amount]
  end

  defmodule TransferMoney do
    defstruct [:account_id, :amount, :payee, :operation_id]
  end

  defmodule ConfirmTransferOperation do
    defstruct [:account_id, :payer, :amount, :operation_id]
  end

  defmodule CompleteTransferOperation do
    defstruct [:account_id, :payee, :amount, :operation_id]
  end
end