defmodule Bank.Account do
  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined, MoneyWithdrawn}
  alias Bank.EventStream

  defstruct id: nil, amount: 0, changes: %EventStream{}

  def new(id) do
    spawn_with {:attempt_command, {:create, id}}
  end

  def load_from_event_stream(event_stream = %EventStream{}) do
    spawn_with {:load_from, event_stream}
  end

  def deposit(pid, amount) do
    send pid, {:attempt_command, {:deposit, amount}}
  end

  def withdraw(pid, amount) do
    send pid, {:attempt_command, {:withdraw, amount}}
  end

  def changes(pid) do
    send pid, {:changes, self()}
    receive do
      {:ok, changes} -> changes
    end
  end

  def loop(state) do
    receive do
      {:attempt_command, command} ->
        {:ok, new_state} = handle(command, state)
        loop(new_state)
      {:load_from, event_stream} ->
        new_state = apply_many_events(event_stream.events, state)
        loop(new_state)
      {:changes, from} ->
        send from, {:ok, changes_from(state)}
        loop(state)
    end
  end

  defp spawn_with(message) do
    pid = spawn(__MODULE__, :loop, [%__MODULE__{}])
    send pid, message
    {:ok, pid}
  end

  defp changes_from(%__MODULE__{id: id, changes: changes}) do
    %EventStream{changes | id: id}
  end

  defp handle({:create, id}, state) do
    event = %AccountCreated{id: id}
    new_state = apply_new_event(event, state)
    {:ok, new_state}
  end

  defp handle({:deposit, amount}, state) do
    event = %MoneyDeposited{id: state.id, amount: amount}
    new_state = apply_new_event(event, state)
    {:ok, new_state}
  end

  defp handle({:withdraw, amount}, state) do
    new_amount = state.amount - amount
    event = case new_amount >= 0 do
      true -> %MoneyWithdrawn{id: state.id, amount: amount}
      false -> %MoneyWithdrawalDeclined{id: state.id, amount: amount}
    end
    new_state = apply_new_event(event, state)
    {:ok, new_state}
  end

  defp handle(_, state), do: {:ok, state}

  defp apply_new_event(event, state) do
    new_state = apply_event(event, state)
    changes = %EventStream{
      version: state.changes.version + 1,
      events: [event|state.changes.events]
    }

    %__MODULE__{new_state | changes: changes}
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

  defp apply_many_events(events, state) do
    events
    |> List.foldr(state, &apply_event(&1, &2))
  end
end
