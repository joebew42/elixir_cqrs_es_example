defmodule Bank.CommandHandlers.CompleteTransferOperation do
  @behaviour Bank.CommandHandler

  alias Bank.Commands.CompleteTransferOperation
  alias Bank.Account

  @impl true
  def handle(%CompleteTransferOperation{} = command) do
    {:ok, version, events} = event_store().load_event_stream(command.account_id)

    account =
      Account.load_from_events(events)
      |> Account.complete_transfer_operation(command.amount, command.payee, command.operation_id)

    :ok = event_store().append_to_stream(command.account_id, version, account.changes)
  end

  defp event_store() do
    Application.get_env(:elixir_cqrs_es_example, :event_store)
  end
end