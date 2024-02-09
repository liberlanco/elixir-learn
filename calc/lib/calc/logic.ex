defmodule Calc.Logic do
  def eval(tree) do
    {:ok, collect_result(tree)}
  end

  defp collect_result({:num, n}), do: n
  defp collect_result({:node, a, :add, b}), do: collect_result(a) + collect_result(b)
  defp collect_result({:node, a, :sub, b}), do: collect_result(a) - collect_result(b)
  defp collect_result({:node, a, :mul, b}), do: collect_result(a) * collect_result(b)
  defp collect_result({:node, a, :div, b}), do: collect_result(a) / collect_result(b)
end
