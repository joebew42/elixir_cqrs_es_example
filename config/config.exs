# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :elixir_cqrs_es_example, event_store: Bank.EventStoreMock
#     import_config "#{Mix.env}.exs"
