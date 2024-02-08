defmodule Calc do
  @moduledoc """
  Documentation for `Calc`.
  """

  @doc """
  Calculate given expression.

  Supported binary operations: - + / *

  ## Examples

      iex> Calc.calculate("2 + 2")
      4

      iex> Calc.calculate("2+2")
      4

      iex> Calc.calculate("2*/4")
      Error: unexpected operation /
  """
  def calculate(exp) do
    with
    {:ok, tree} <- Calc.Parser.parse(exp)

    {:ok, res} <-
      Calc.Logic.eval tree do
        IO.puts(res)
      else
        {:error, reason} -> IO.puts("Error:", reason)
      end
  end
end
