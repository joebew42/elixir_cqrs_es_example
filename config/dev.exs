use Mix.Config

config :elixir_cqrs_es_example, event_store: Bank.InMemoryEventStore
config :elixir_cqrs_es_example, event_publisher: Bank.EventBusPublisher