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
end