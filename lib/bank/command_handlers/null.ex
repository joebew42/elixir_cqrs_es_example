defmodule Bank.CommandHandlers.Null do
  @behaviour Bank.CommandHandler

  @impl true
  def handle(_) do
    :nothing
  end
end