defmodule Calc.Logic do
  def eval(tree) do
    {:ok, collect_result(tree)}
  end

  defp collect_result({n}), do: n
  defp collect_result({a, :+, b}), do: collect_result(a) + collect_result(b)
  defp collect_result({a, :-, b}), do: collect_result(a) - collect_result(b)
  defp collect_result({a, :*, b}), do: collect_result(a) * collect_result(b)
  defp collect_result({a, :/, b}), do: collect_result(a) / collect_result(b)
end
