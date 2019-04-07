defmodule Bank.Account do
  defstruct id: nil, amount: 0, changes: []

  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined,
                    MoneyWithdrawn, TransferOperationOpened}

  def new(%__MODULE__{id: nil, amount: 0} = state, id) do
    apply_new_event(%AccountCreated{id: id}, state)
  end

  def deposit(%__MODULE__{id: id} = state, amount) when is_binary(id) do
    apply_new_event(%MoneyDeposited{id: id, amount: amount}, state)
  end

  def withdraw(%__MODULE__{id: id, amount: current_amount} = state, amount) when is_binary(id) and current_amount - amount >= 0 do
    apply_new_event(%MoneyWithdrawn{id: id, amount: amount}, state)
  end

  def withdraw(%__MODULE__{id: id} = state, amount) when is_binary(id) do
    apply_new_event(%MoneyWithdrawalDeclined{id: id, amount: amount}, state)
  end

  def transfer(%__MODULE__{id: id} = state, amount, payee, operation_id) do
    %__MODULE__{state | changes: [%TransferOperationOpened{id: id, amount: amount, payee: payee, operation_id: operation_id}]}
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
    %__MODULE__{state | amount: state.amount + deposited_amount}
  end

  defp apply_event(%MoneyWithdrawalDeclined{}, state) do
    state
  end

  defp apply_event(%MoneyWithdrawn{amount: withdrawn_amount}, state) do
    %__MODULE__{state | amount: state.amount - withdrawn_amount}
  end
end
