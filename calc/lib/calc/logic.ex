defmodule Calc.Logic do
  @moduledoc """
  Module to evaluate expression formatted as tree, and return the result.
  """

  @doc """
  Calculates evaluation tree and returns the result

  ### Examples

      iex(2)> Calc.Logic.eval({:node, {:node, {:num, 2.0}, :mul, {:num, 3.0}}, :add, {:num, 4.0}})
      {:ok, 10.0}
  """
  def eval(tree) do
    {:ok, collect_result(tree)}
  end

  defp collect_result({:num, n}), do: n
  defp collect_result({:node, a, :add, b}), do: collect_result(a) + collect_result(b)
  defp collect_result({:node, a, :sub, b}), do: collect_result(a) - collect_result(b)
  defp collect_result({:node, a, :mul, b}), do: collect_result(a) * collect_result(b)
  defp collect_result({:node, a, :div, b}), do: collect_result(a) / collect_result(b)
end
