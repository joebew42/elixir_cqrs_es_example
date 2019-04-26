defmodule Bank.CommandBus do

  @default_handlers Application.get_env(:elixir_cqrs_es_example, :command_handlers)

  def send(command, handlers \\ @default_handlers) do
    command_handler = handler_for(command.__struct__, handlers)
    command_handler.handle(command)
  end

  defp handler_for(command_name, handlers) do
    handlers
    |> Map.get(command_name, Bank.CommandHandlers.Null)
  end
end
