defmodule Calc do
  @moduledoc """
  Main interfaces for calculator.

  It's a simple calculator with support of operation priorities, unuary operation - (negative)
  and parentheses. Uses RDP (recursive descent parser) to convert tokens to AST.

  Use `eval/1` in code as API. And use `calculate/1` as
  human interfaces with IO.puts
  """

  @spec eval(String.t()) :: {:ok, float()} | {:error, String.t()}
  @doc """
  Calculate given expression.

  Supported binary operations: -, +, /, *,
  Supprted unuary operatiuon: - (negative)
  Supported brackets: (, )

  ## Examples

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
