use Mix.Config

config :elixir_cqrs_es_example,
  command_handlers: %{
    Bank.Commands.CreateAccount => Bank.CommandHandlers.CreateAccount,
    Bank.Commands.DepositMoney  => Bank.CommandHandlers.DepositMoney,
    Bank.Commands.WithdrawMoney => Bank.CommandHandlers.WithdrawMoney
  }

import_config "#{Mix.env()}.exs"
