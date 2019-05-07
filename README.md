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

- Introduce the use of a GUID for the aggregateId
  - In this case probably is the `Bank.Client` that have to generate the GUID based on the `name` (to guarantee the uniqueness of `name`)?

## Questions & TODOs

- Whenever I want to confirm or complete a transfer operation there is no check at aggregate level (e.g. from the payer perspective: is there a `TransferOperationOpened` when the aggregate receive a `CompleteTransferOperation`?)
- Should the `CommandBus` [raise exceptions](https://github.com/gregoryyoung/m-r/blob/master/SimpleCQRS/FakeBus.cs)?
- What about the idea to use a `ProcessId` (or `CommandId`) to identify or remember the [originator of the command in the event](http://danielwhittaker.me/2014/10/18/6-code-smells-cqrs-events-avoid/)?
- How to deal with the state of the Process Manager when replaying events?
  - It seems that [Process Managers can persist their state](https://tech.just-eat.com/2015/05/26/process-managers/)
- Inject collaborators instead of using functions
- Probably the `EventHandler` is the [`AccountProjections`](https://github.com/gregoryyoung/m-r/blob/master/SimpleCQRS/ReadModel.cs) that listen to some specific events in order to update the view (can we reuse the same pattern adopted for the `TransferOperation`s?)
- Add a new projection that provide the list of all the available accounts with the current account balance
- Add a new projection that provide the list of all operations made on a specific account
- Try to add a policy for event conflicts resolution
  - https://tech.zilverline.com/2012/08/08/simple-event-sourcing-conflict-resolution-part-4
  - https://medium.com/@teivah/event-sourcing-and-concurrent-updates-32354ec26a4c
  - http://danielwhittaker.me/2014/09/29/handling-concurrency-issues-cqrs-event-sourced-system/
  - https://dzone.com/articles/the-good-of-event-sourcing-conflict-handling-repli
- There is some duplicated code in the command handlers tests (e.g., `expect_never` and some aliases and imports)
- Could we consider to introduce an AccountRepository to hide the detail about the EventStore in the command handlers?
- Should the EventDescriptor have the aggregateId?
- Consider to return the changes from the first to the latest, and also following this order in the event store
- Probably the InMemoryEventStore is the EventStore itself. What should change is where the event descriptors are stored. Think about it!
- EventHandler is too big and quite difficult to test.
  - Probably is better to decouple the logic from the implementation (GenServer)
  - Have different event handler based on the event
  - Consider to use [Task](https://hexdocs.pm/elixir/Task.html)s
- Consider to save the latest version as a detail for the read model
- Improve the setup of the acceptance test
- Consider to run a `mix format` to see what happen :)

## DONE

- Update the `Account` view on `TransferOperationCompleted`
- Add the `CompleteTransferOperation` command handler
- Create and example of how a money transfer between two bank accounts could be
  - Introduce a `TransferOperationManager` ...
    - Try to [separate the implementation from the domain logic](https://pragdave.me/blog/2017/07/13/decoupling-interface-and-implementation-in-elixir.html)
      - `TransferOperationProcess` (implementation: GenServer + State)
      - `TransferOperationManager` (domain logic)
  - Now that I can send a `TransferOperationOpened` I could be able to finalize the transaction
    - Should I use the concept of Process Managers ? Where we have a Process Manager for each operation_id?
    - Is the money transfer a long running
  - References about Process Manager
    - [EIP](https://www.enterpriseintegrationpatterns.com/patterns/messaging/ProcessManager.html)
    - [Process Manager and Events Flow](https://www.infoq.com/news/2017/07/process-managers-event-flows)
- `CommandBus.publish` should be `send`, better to extract a behaviour for the commandbus
  - Maybe we don't need a command bus to subscribe on. Think about ...
- Introduce the concept of `Account Balance` and `Available Balance`
- Do not use the task supervisor for now
- Move default_handlers as configuration
- Consider to use [Supervised Tasks](https://hexdocs.pm/elixir/Task.html#module-supervised-tasks)s to run commands
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

## TRASHED / NOT NEEDED

- In order to reduce the concurrency exception, one solution could be to serialize the execution of commands related to the same aggregate id
  - At the moment the TaskSupervisor is disabled
- Should the `CommandHandler` return errors?
- `Bank` will act as a client that will send commands
- When handle the `deposit_money` command we should check if the `account` process is running
- `EventBus` and `CommandBus` are quite similar
- What about an `AccountRepository` to `find` and `save` accounts?
- When to flush all the `changes` of the `Account`?
- Does `Account`s may to be supervised?
- Extract the `via_registry` out from `Account` (the business logic should be decoupled from the genserver)
- Elixir: Is it possible to configure the application through environment variables?
- Maybe the responsabilities to `create` and `find` an `Account` should be delegated to the `AccountRepository`, and we may think to rename it as `Accounts`?
- [?] Implement an `EventStoreAccountRepository`

## FINAL NOTES

- At the moment `Account.confirm_transfer_operation` is deliberately simplified. It does not take care of the `payer` and `operation_id`. So, there is no check if the operation is already confirmed, or not.

## Extras

Run multiple calls:

```
Enum.each(1..10, fn(i) -> Task.start(fn() -> Process.sleep(:rand.uniform(5) * 100); Bank.Client.deposit("ACCOUNT", 1) end) end)
```
