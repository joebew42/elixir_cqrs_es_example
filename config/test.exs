use Mix.Config

config :elixir_cqrs_es_example,
  command_bus: Bank.CommandBusMock,
  event_store: Bank.EventStoreMock,
  event_publisher: Bank.EventPublisherMock,
  account_read_model: Bank.AccountReadModelMock,
  transfer_operation_process_manager: Bank.ProcessManagerMock