defmodule Bank.TransferOperationServer do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: :transfer_operation_server)
  end

  def init(nil) do
    Bank.EventBus.subscribe(self())
    {:ok, %{}}
  end

  def handle_cast(event, state) do
    new_state = process_manager().handle(event, state)

    {:noreply, new_state}
  end

  defp process_manager() do
    Application.get_env(:elixir_cqrs_es_example, :transfer_operation_process_manager)
  end
end
