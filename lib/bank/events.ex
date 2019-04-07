defmodule Bank.Events do
  defmodule AccountCreated do
    defstruct [:id]
  end

  defmodule MoneyDeposited do
    defstruct [:id, :amount]
  end

  defmodule MoneyWithdrawalDeclined do
    defstruct [:id, :amount]
  end

  defmodule MoneyWithdrawn do
    defstruct [:id, :amount]
  end

  defmodule TransferOperationOpened do
    defstruct [:id, :amount, :payee, :operation_id]
  end
end