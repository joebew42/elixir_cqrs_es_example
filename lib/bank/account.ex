defmodule Bank.Account do
  use GenServer

  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawalDeclined, MoneyWithdrawn}
  alias Bank.EventStream

  defstruct id: nil, amount: 0, changes: %EventStream{}

  def new(id) do
    start_with(id, {:create, id})
  end

  def load_from_event_stream(event_stream = %EventStream{id: id}) do
    start_with(id, {:load_from, event_stream})
  end

  defp start_with(id, message) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %__MODULE__{}, name: via_registry(id))
    send pid, message
    {:ok, id}
  end

  defp via_registry(id), do: {:via, Registry, {Bank.Registry, id}}

  def init(args), do: {:ok, args}

  def deposit(id, amount) do
    GenServer.call(via_registry(id), {:deposit, amount})
  end

  def withdraw(id, amount) do
    GenServer.call(via_registry(id), {:withdraw, amount})
  end

  def changes(id) do
    GenServer.call(via_registry(id), :changes)
  end

  def handle_call(:changes, _pid, state) do
    {:reply, changes_from(state), state}
  end

  def handle_call({:deposit, amount}, _pid, state) do
    event = %MoneyDeposited{id: state.id, amount: amount}
    new_state = apply_new_event(event, state)
    {:reply, :ok, new_state}
  end

  def handle_call({:withdraw, amount}, _pid, state) do
    new_amount = state.amount - amount
    event = case new_amount >= 0 do
      true -> %MoneyWithdrawn{id: state.id, amount: amount}
      false -> %MoneyWithdrawalDeclined{id: state.id, amount: amount}
    end
    new_state = apply_new_event(event, state)
    {:reply, :ok, new_state}
  end

  def handle_call(_, _pid, state), do: {:reply, :ok, state}

  def handle_info({:create, id}, state) do
    event = %AccountCreated{id: id}
    new_state = apply_new_event(event, state)
    {:noreply, new_state}
  end

  def handle_info({:load_from, event_stream}, state) do
    new_state =
      apply_many_events(event_stream.events, state)
      |> update_version(event_stream.version)

    {:noreply, new_state}
  end

  defp changes_from(%__MODULE__{id: id, changes: changes}) do
    %EventStream{changes | id: id}
  end

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

  defp update_version(state, version) do
    %__MODULE__{state | changes: %EventStream{state.changes | version: version}}
  end
end
