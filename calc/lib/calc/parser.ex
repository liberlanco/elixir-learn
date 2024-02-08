defmodule Calc.Parser do
  def parse(exp) do
    tokens =
      exp
      |> to_charlist
      |> tokenize

    build_tree(tokens)
  end

  def tokenize(list), do: tokenize(list, [])

  defp tokenize([], acc), do: reverse(acc)
  defp tokenize([" " | tail], acc), do: tokenize(tail, acc)
  defp tokenize(["+" | tail], acc), do: tokenize(tail, [:add | acc])
  defp tokenize(["-" | tail], acc), do: tokenize(tail, [:sub | acc])
  defp tokenize(["/" | tail], acc), do: tokenize(tail, [:div | acc])
  defp tokenize(["*" | tail], acc), do: tokenize(tail, [:mul | acc])

  defp tokenize([ch | tail], [prev_ch | acc]) when is_binary(old_ch) do
    tokenize(tail, [prev_ch <> ch | acc])
  end

  def build_tree(tokens), do: build_tree(tokens, [])

  defp build_tree([n], []), {n}
end
