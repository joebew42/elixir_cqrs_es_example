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

- Write an Acceptance Test

## Questions & TODOs

- Use Mox and introduce a behaviour for the `AccountRepository`
- [?] Implement an `EventStoreAccountRepository`
- Implement an InMemory `EventStore`
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
