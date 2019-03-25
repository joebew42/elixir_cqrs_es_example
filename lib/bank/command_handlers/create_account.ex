defmodule Bank.CommandHandlers.CreateAccount do
  @behaviour Bank.CommandHandler

  alias Bank.Commands.CreateAccount
  alias Bank.Account

  @impl true
  def handle(%CreateAccount{} = command) do
    case event_store().load_event_stream(command.id) do
      {:ok, _version, _changes} ->
        :nothing
      {:error, :not_found} ->
        account =
          %Account{}
          |> Account.new(command.id)

        :ok = event_store().append_to_stream(command.id, -1, account.changes)
    end
  end

  defp event_store() do
    Application.get_env(:elixir_cqrs_es_example, :event_store)
  end
end