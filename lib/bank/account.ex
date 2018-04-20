defmodule Bank.Account do
  defstruct id: nil, amount: 0, changes: []

  alias Bank.Events.{AccountCreated, MoneyDeposited}
  alias Bank.EventStream

  def new() do
    pid = spawn(__MODULE__, :loop, [%__MODULE__{}])
    {:ok, pid}
  end

  def create(pid, id) do
    send pid, {:attempt_command, {:create, id}}
  end

  def deposit(pid, amount) do
    send pid, {:attempt_command, {:deposit, amount}}
  end

  def load_from_event_stream(pid, %EventStream{version: _version, events: events}) do
    send pid, {:load_from, events}
  end

  def changes(pid) do
    send pid, {:attempt_query, {:changes, self()}}
    receive do
      {:ok, changes} -> changes
    end
  end

  def loop(state) do
    receive do
      {:attempt_query, {query, from}} ->
        handle(query, from, state)
        loop(state)
      {:attempt_command, command} ->
        {:ok, new_state} = handle(command, state)
        loop(new_state)
      {:load_from, events} ->
        new_state = apply_many_events(events, state)
        loop(new_state)
    end
  end

  defp handle(:changes, from, state) do
    send from, {:ok, state.changes}
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

  defp handle(_, state), do: {:ok, state}

  defp apply_new_event(event, state) do
    new_state = apply_event(event, state)
    %__MODULE__{new_state | changes: [event|state.changes]}
  end

  defp apply_event(%AccountCreated{id: id}, state) do
    %__MODULE__{state | id: id}
  end

  defp apply_event(%MoneyDeposited{amount: deposited_amount}, state) do
    %__MODULE__{state | amount: state.amount + deposited_amount}
  end

  defp apply_many_events(events, state) do
    events
    |> List.foldr(state, &apply_event(&1, &2))
  end
end