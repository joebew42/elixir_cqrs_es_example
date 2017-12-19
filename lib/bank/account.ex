defmodule Bank.Account do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, %{})
  end

  def create(pid, id) do
    GenServer.call(pid, {:attempt_command, {:create, id}})
  end

  def id(pid) do
    GenServer.call(pid, {:id})
  end

  def handle_call({:attempt_command, command}, _from, state) do
    new_state = attempt_command(command, state)
    {:reply, :ok, new_state}
  end

  def handle_call({:id}, _from,  state) do
    {:reply, Map.get(state, :id), state}
  end

  defp attempt_command({:create, id}, state) do
    # TODO
    # Continue from: https://github.com/bryanhunter/cqrs-with-erlang/blob/ndc-london/bank/src/bank_account.erl
    %{id: "Joe"}
  end
end
