# SupervisorTest

Test how supervisors stablize code in case of bad states.

`DataEmitter` - single process that calls random `Worker` each `@interval`.
Each process is called with number 0-999

`Worker` - responds to DataEmitter. Each number NUM is processed by following logic:
- NUM in [100, 200, ...] - introduce corrupted state (an_error - random number 0-99).
- NUM rem an_error == 0 - crash
- work with `Base`, :ok

`Base` - global process, that is called by each `Worker`. From time to time
it can go into corrupted process. In this case any attempt to work with base
will return {:error, :corrupted_state}

Supervisors should restart

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `supervisor_test` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:supervisor_test, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/supervisor_test>.

