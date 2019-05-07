defmodule Bank.CommandHandlers.CreateAccount do
  @behaviour Bank.CommandHandler

  alias Bank.Commands.CreateAccount
  alias Bank.Account

  @impl true
  def handle(%CreateAccount{account_id: account_id, name: name}) do
    case event_store().load_event_stream(account_id) do
      {:ok, _version, _changes} ->
        :nothing
      {:error, :not_found} ->
        account =
          %Account{}
          |> Account.new(account_id, name)

        :ok = event_store().append_to_stream(account_id, -1, account.changes)
    end
  end

  defp event_store() do
    Application.get_env(:elixir_cqrs_es_example, :event_store)
  end
end