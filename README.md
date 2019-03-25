# ElixirCqrsEsExample

This is an Elixir port of the [cqrs with erlang](https://github.com/bryanhunter/cqrs-with-erlang).

I tried to understand how this system can be tested, so if you are interested about the testing take a look a the tests.

## Installation

```
mix deps.get
```

## Run all tests

```
mix test --include acceptance
```

## Run only acceptance tests

```
mix test --only acceptance
```

## DOING

- Consider to use [Supervised Tasks](https://hexdocs.pm/elixir/Task.html#module-supervised-tasks)s to run commands

## Questions & TODOs

- There is some duplicated code in the command handlers tests (e.g., `expect_never` and some aliases and imports)
- Could we consider to introduce an AccountRepository to hide the detail about the EventStore in the command handlers?
- Introduce the use of a GUID for the aggregateId
- Should the EventDescriptor have the aggregateId?
- Consider to return the changes from the first to the latest, and also following this order in the event store
- Probably the InMemoryEventStore is the EventStore itself. What should change is where the event descriptors are stored. Think about it!
- EventHandler is too big and quite difficult to test.
  - Probably is better to decouple the logic from the implementation (GenServer)
  - Have different event handler based on the event
  - Consider to use [Task](https://hexdocs.pm/elixir/Task.html)s
- Consider to save the latest version as a detail for the read model
- Improve the setup of the acceptance test
- Should the `CommandHandler` return errors?
- `Bank` will act as a client that will send commands
- When handle the `deposit_money` command we should check if the `account` process is running
- `EventBus` and `CommandBus` are quite similar

## DONE

- Introduce Task to run commands
- CommandHandler is too big and quite difficult to test.
- What to test for the `CommandHandler`?
- Have different command handler based on the command
- Decouple the logic of command handlers from the GenServer implementation
- CommandHandler handles cast
- Account should not be a process
  - it should act as a set of transition functions (fn(current_state, action) -> [events])
  - also, we are not cleaning up the uncommitted changes
  - and also, the account processes are created as child of the command handler! Ouch!
- Provide a read model (view/projection) for the BankAccount
- How to handle concurrent issue in the `EventStore.append_to_stream`?
- Handle the `expected_version` when trying to append new events `EventStore.append_to_stream`
- Based on the [source](https://github.com/gregoryyoung/m-r/blob/master/SimpleCQRS/EventStore.cs), another responsability of the event store is to publish events once they are saved. Do we need to move this responsability elsewhere? Or we can proceed to maintain it there?
  - At the moment we say that is a responsability of the EventStore to publish the events once they are stored
- Provide an implementation of the `EventPublisher` to publish events via `EventBus`
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

## TRASHED

- What about an `AccountRepository` to `find` and `save` accounts?
- When to flush all the `changes` of the `Account`?
- Does `Account`s may to be supervised?
- Extract the `via_registry` out from `Account` (the business logic should be decoupled from the genserver)
- Elixir: Is it possible to configure the application through environment variables?
- Maybe the responsabilities to `create` and `find` an `Account` should be delegated to the `AccountRepository`, and we may think to rename it as `Accounts`?
- [?] Implement an `EventStoreAccountRepository`
