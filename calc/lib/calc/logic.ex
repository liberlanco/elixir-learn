defmodule Calc.Logic do
  @moduledoc """
  Module to evaluate expression formatted as tree, and return the result.
  """

  @doc """
  Calculates evaluation tree and returns the result

  ## Examples

      iex(5)> Calc.Logic.eval({:add, {:neg, {:num, 2.0}}, {:div, {:num, 3.0}, {:num, 4.0}}})
      {:ok, -1.25}
  """
  def eval(tree) do
    {:ok, collect_result(tree)}
  end

  defp collect_result({:num, n}), do: n
  defp collect_result({:add, a, b}), do: collect_result(a) + collect_result(b)
  defp collect_result({:sub, a, b}), do: collect_result(a) - collect_result(b)
  defp collect_result({:mul, a, b}), do: collect_result(a) * collect_result(b)
  defp collect_result({:div, a, b}), do: collect_result(a) / collect_result(b)
  defp collect_result({:neg, a}), do: 0 - collect_result(a)
end
