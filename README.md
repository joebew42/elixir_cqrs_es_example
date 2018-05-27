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

- Introduce an `AccountRepository` that will act as a repository for `Account`, and it will be used by the `BankService`
  - Move the withdrawn out of the BankService

## Questions & TODOs

- Should the `CommandHandler` return errors?
- `Account` may be able to create named processes, so that we can easily identiy `Account`s by their names intead of `pid`s
- `Bank` will act as a client that will send commands
- How to handle concurrent issue in the `EventStore.append_to_stream`?
- When handle the `deposit_money` command we should check if the `account` process is running
- When to flush all the `changes` of the `Account`?
- When to use a `Service`? Should the `command_handler` deal with a `BankService`?

## DONE

- `EventStore.append_to_stream` should return `:ok` and not `{:ok}`
- Consider to return an `EventStream` instead of a list when doing `Account.changes(...)`
- `Accounts` should be a `BankService`. It is stateless and will collaborate with the `AccountRepository`
