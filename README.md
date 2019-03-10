# ElixirCqrsEsExample

This is an Elixir port of the [cqrs with erlang](https://github.com/bryanhunter/cqrs-with-erlang).

I tried to understand how this system can be tested, so if you are interested about the testing take a look a the tests.

## Installation

```
mix deps.get
```

## Run all tests

```
mix test
```

## DOING

- The EventBus should be an implementation of the EventPublisher. It could be an `EventBusEventPublisher`

## Questions & TODOs

- The EventDescriptor should have the aggregateId
- Consider to return the changes from the first to the latest, and also following this order in the event store
- Based on the [source](https://github.com/gregoryyoung/m-r/blob/master/SimpleCQRS/EventStore.cs), another responsability of the event store is to publish events once they are saved. Do we need to move this responsability elsewhere? Or we can proceed to maintain it there?
- Probably the InMemoryEventStore will be the EventStore, itself. What should change is where the event descriptors are stored. Think about it!
- Elixir: Is it possible to configure the application through environment variables?
- Extract the `via_registry` out from `Account`
- Handle the `expected_version` when trying to append new events `EventStore.append_to_stream`
- [?] Implement an `EventStoreAccountRepository`
- Maybe the responsabilities to `create` and `find` an `Account` should be delegated to the `AccountRepository`, and we may think to rename it as `Accounts`?
- Does `Account`s may to be supervised?
- Should the `CommandHandler` return errors?
- `Bank` will act as a client that will send commands
- How to handle concurrent issue in the `EventStore.append_to_stream`?
- When handle the `deposit_money` command we should check if the `account` process is running
- When to flush all the `changes` of the `Account`?
- When to use a `Service`? Should the `command_handler` deal with a `BankService`?
- `EventBus` and `CommandBus` are quite similar

## DONE

- Publish the events to the EventBus once the events have been stored
- Implement an InMemory `EventStore` ([source](https://github.com/gregoryyoung/m-r/blob/master/SimpleCQRS/EventStore.cs))
- Probably we could consider to review the tests of the InMemoryEventStore. Test the behaviour and not the functions!
- Check that the events are stored in the correct order
- Check that the version follows the correct numerical progression
- Remove EventStream
- Use Mox instead of Mock
- [!] Remove `BankService`
- Write an Acceptance Test
- `AccountRepository` should deal with the `id` and not with the `pid`
- We may have to introduce an `EventBus`
- `Account.load_from_event_stream` is not tested
- `Account` may be able to create named processes, so that we can easily identiy `Account`s by their names intead of `pid`s
- Introduce a `Registry` for `Account` named process
- Introduce an `AccountRepository` that will act as a repository for `Account`, and it will be used by the `BankService`
  - Move the withdrawn out of the BankService
- `EventStore.append_to_stream` should return `:ok` and not `{:ok}`
- Consider to return an `EventStream` instead of a list when doing `Account.changes(...)`
- `Accounts` should be a `BankService`. It is stateless and will collaborate with the `AccountRepository`
