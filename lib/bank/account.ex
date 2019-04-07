defmodule Bank.Account do
  defstruct id: nil, available_balance: 0, account_balance: 0, changes: []

  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined,
                    MoneyWithdrawn, TransferOperationOpened, TransferOperationDeclined}

  def new(%__MODULE__{id: nil} = state, id) do
    apply_new_event(%AccountCreated{id: id}, state)
  end

  def deposit(%__MODULE__{id: id} = state, amount) when is_binary(id) do
    apply_new_event(%MoneyDeposited{id: id, amount: amount}, state)
  end

  def withdraw(%__MODULE__{id: id, available_balance: current_available_balance} = state, amount) do
    new_event = case current_available_balance >= amount do
      true ->
        %MoneyWithdrawn{id: id, amount: amount}
      false ->
        %MoneyWithdrawalDeclined{id: id, amount: amount}
    end

    apply_new_event(new_event, state)
  end

  def transfer(%__MODULE__{id: id} = state, amount, payee, operation_id) do
    new_event = case state.account_balance >= amount do
      true ->
        %TransferOperationOpened{
          id: id,
          amount: amount,
          payee: payee,
          operation_id: operation_id
        }
      false ->
        %TransferOperationDeclined{
          id: id,
          amount: amount,
          payee: payee,
          operation_id: operation_id,
          reason: "insufficient funds"
        }
    end

    apply_new_event(new_event, state)
  end

  defp apply_new_event(event, state) do
    new_state = apply_event(event, state)

    %__MODULE__{new_state | changes: [event | state.changes]}
  end

  def load_from_events(events) do
    List.foldr(events, %__MODULE__{}, &apply_event(&1, &2))
  end

  defp apply_event(%AccountCreated{id: id}, state) do
    %__MODULE__{state | id: id}
  end

  defp apply_event(%MoneyDeposited{amount: deposited_amount}, state) do
    %__MODULE__{state |
      available_balance: state.available_balance + deposited_amount,
      account_balance: state.account_balance + deposited_amount
    }
  end

  defp apply_event(%MoneyWithdrawalDeclined{}, state) do
    state
  end

  defp apply_event(%MoneyWithdrawn{amount: withdrawn_amount}, state) do
    %__MODULE__{state |
      available_balance: state.available_balance - withdrawn_amount,
      account_balance: state.account_balance - withdrawn_amount
    }
  end

  defp apply_event(%TransferOperationOpened{amount: amount}, state) do
    %__MODULE__{state | account_balance: state.account_balance - amount}
  end

  defp apply_event(%TransferOperationDeclined{}, state) do
    state
  end
end
