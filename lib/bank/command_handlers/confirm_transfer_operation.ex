defmodule Bank.CommandHandlers.ConfirmTransferOperation do
  @behaviour Bank.CommandHandler

  alias Bank.Commands.ConfirmTransferOperation
  alias Bank.Account

  @impl true
  def handle(%ConfirmTransferOperation{} = command) do
    {:ok, version, events} = event_store().load_event_stream(command.id)

    account =
      Account.load_from_events(events)
      |> Account.confirm_transfer_operation(command.amount, command.payer, command.operation_id)

    :ok = event_store().append_to_stream(command.id, version, account.changes)
  end

  defp event_store() do
    Application.get_env(:elixir_cqrs_es_example, :event_store)
  end
end