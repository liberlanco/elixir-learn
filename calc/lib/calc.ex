defmodule Calc do
  @moduledoc """
  Main interfaces for calculator.

  It's a simple calculator, no support for operation priorities, no sofisticated error handling
  of wrong input, no support for brackets and other complex things like negative numbers in the
  middle of input

  Use `eval` in code as API. And use `calculate` as
  human interfaces with IO.puts
  """

  @spec eval(String.t()) :: {:ok, float()} | {:error, String.t()}
  @doc """
  Calculate given expression.

  Supported binary operations: - + / *

  ## Examples

      iex> Calc.eval("2 + 2")
      {:ok, 4.0}

      iex> Calc.eval("2+2")
      {:ok, 4.0}

      iex> Calc.eval("2 + 2 * 2e10")
      {:ok, 80000000000.0}

      iex> Calc.eval("2 / 0")
      ** (ArithmeticError) bad argument in arithmetic expression
  """
  def eval(exp) do
    with {:ok, tree} <- Calc.Parser.parse(exp),
         {:ok, res} <- Calc.Logic.eval(tree) do
      {:ok, res}
    end
  end

  @spec calculate(String.t()) :: :ok
  @doc """
  Human interface for calculator. Does IO.puts instead of
  API output
  """
  def calculate(exp) do
    case eval(exp) do
      {:ok, res} -> IO.puts(res)
      {:error, reason} -> IO.puts("Error: #{reason}")
    end
  end
end
