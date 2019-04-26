use Mix.Config

config :elixir_cqrs_es_example,
  command_bud: Bank.DefaultCommandBus,
  event_store: Bank.InMemoryEventStore,
  event_publisher: Bank.EventBusPublisher,
  account_read_model: Bank.InMemoryAccountReadModel,
  transfer_operation_process_manager: Bank.TransferOperationProcessManager