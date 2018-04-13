defmodule Bank.Account do
  defstruct id: nil, changes: []

  alias Bank.Events.AccountCreated

  def new() do
    pid = spawn(__MODULE__, :loop, [%__MODULE__{}])
    {:ok, pid}
  end

  def create(pid, id) do
    send pid, {:attempt_command, {:create, id}}
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

  defp handle(_, state), do: {:ok, state}

  defp apply_new_event(event, state) do
    new_state = apply_event(event, state)
    %__MODULE__{new_state | changes: [event|state.changes]}
  end

  defp apply_event(%AccountCreated{id: id}, state) do
    %__MODULE__{state | id: id}
  end
end