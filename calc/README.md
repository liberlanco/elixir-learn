# Calc

Calculator labrary. Parser and evaluates simple mathematical expression.

Supported binary operations: -, +, /, *,
Supprted unuary operatiuon: - (negative)
Supported brackets: (, )

## Examples

```elixir
iex> Calc.eval("2 + 2")
{:ok, 4.0}

iex> Calc.eval("2+2")
{:ok, 4.0}

iex> Calc.eval("2 + 2 * 2e10")
{:ok, 40000000002.0}

iex(9)> Calc.eval("2 +")
{:error, "missing argument"}

iex> Calc.eval("2 / 0")
** (ArithmeticError) bad argument in arithmetic expression
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `calc` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:calc, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/calc>.

