use Mix.Config

config :elixir_cqrs_es_example, event_store: Bank.EventStoreMock
config :elixir_cqrs_es_example, event_publisher: Bank.EventPublisherMock

config :elixir_cqrs_es_example, account_read_model: Bank.AccountReadModelMock

config :elixir_cqrs_es_example, transfer_operation_process_manager: Bank.ProcessManagerMock