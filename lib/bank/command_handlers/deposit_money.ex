defmodule Bank.CommandHandlers.DepositMoney do

  alias Bank.Commands.DepositMoney
  alias Bank.Account

  def handle(%DepositMoney{} = command) do
    case event_store().load_event_stream(command.id) do
      {:ok, version, events} ->
        account =
          Account.load_from_events(events)
          |> Account.deposit(command.amount)

        :ok = event_store().append_to_stream(command.id, version, account.changes)
      {:error, :not_found} ->
        :nothing
    end
  end

  defp event_store() do
    Application.get_env(:elixir_cqrs_es_example, :event_store)
  end
end