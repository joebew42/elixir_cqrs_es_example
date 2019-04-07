defmodule Bank.CommandHandlers.TransferMoney do
  @behaviour Bank.CommandHandler

  alias Bank.Commands.TransferMoney
  alias Bank.Account

  @impl true
  def handle(%TransferMoney{} = command) do
    case event_store().load_event_stream(command.id) do
      {:ok, version, events} ->
        account =
          Account.load_from_events(events)
          |> Account.transfer(command.amount, command.payee, command.operation_id)

        :ok = event_store().append_to_stream(command.id, version, account.changes)
      {:error, :not_found} ->
        :nothing
    end
  end

  defp event_store() do
    Application.get_env(:elixir_cqrs_es_example, :event_store)
  end
end