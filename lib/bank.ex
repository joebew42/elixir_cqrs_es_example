defmodule Bank do
  use Application

  def start(_type, _args) do
    Bank.Supervisor.start_link([
      command_handlers: Application.get_env(:elixir_cqrs_es_example, :command_handlers)
    ])
  end
end