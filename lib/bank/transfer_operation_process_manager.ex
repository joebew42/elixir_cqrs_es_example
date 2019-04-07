defmodule Bank.TransferOperationProcessManager do
  @behaviour Bank.ProcessManager

  alias Bank.Events

  @impl true
  def on(%Events.TransferOperationOpened{operation_id: operation_id}, %{} = state) do
    Map.put(state, operation_id, :pending_confirmation)
  end

end
