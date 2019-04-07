use Mix.Config

config :elixir_cqrs_es_example, event_store: Bank.InMemoryEventStore
config :elixir_cqrs_es_example, event_publisher: Bank.EventBusPublisher

config :elixir_cqrs_es_example, account_read_model: Bank.InMemoryAccountReadModel

config :elixir_cqrs_es_example, transfer_operation_process_manager: Bank.TransferOperationProcessManager