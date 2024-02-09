defmodule Calc do
  @moduledoc """
  Main interfaces for calculator.

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
