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


## Questions & TODOs

- `Bank` will act as a client that will send commands
- Introduce an `Accounts` that will act as a repository for `Account`
- How to handle concurrent issue in the `EventStore.append_to_stream`?
- When handle the `deposit_money` command we should check if the `account` process is running
- When to flush all the `changes` of the `Account`?
- When to use a `Service`? Should the `command_handler` deal with a `BankService`?

## DONE

- `Accounts` should be a `BankService`. It is stateless and will collaborate with the `AccountRepository`
