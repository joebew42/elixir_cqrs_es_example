defmodule Bank.TransferOperationProcessManager do
  @behaviour Bank.ProcessManager

  alias Bank.Events
  alias Bank.Commands

  @impl true
  def on(%Events.TransferOperationOpened{} = event, %{} = operations) do
    :ok = command_bus().send(%Commands.ConfirmTransferOperation{
      id: event.payee,
      payer: event.id,
      amount: event.amount,
      operation_id: event.operation_id
    })

    switch(operations, to: :pending_confirmation, for: event.operation_id)
  end

  defp switch(operations, to: next_state, for: operation_id) do
    Map.put(operations, operation_id, next_state)
  end

  defp command_bus() do
    Application.get_env(:elixir_cqrs_es_example, :command_bus)
  end
end
