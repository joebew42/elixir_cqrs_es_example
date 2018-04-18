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

## Questions

- When to flush all the `changes` of the `Account`?
- When to use a `Service`? Should the `command_handler` deal with a `BankService`?