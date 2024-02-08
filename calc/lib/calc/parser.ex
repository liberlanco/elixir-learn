defmodule Calc.Parser do
  @doc """
    Parses givem string with expression and returns operation tree
  """
  def parse(exp) do
    exp
    |> tokenize
    |> build_tree
  end

  defguard is_op(op) when is_atom(op) and op in [:add, :mul, :div, :sub]

  @doc """
  Tokenize given string, convert all numbers to floats

  ### Examples

     iex> Calc.Parser.tokenize("14 + 21 - 13 + 43 * -55")
     {:ok, [14.0, :add, 21.0, :sub, 13.0, :add, 43.0, :mul, :sub, 55.0]}

     iex> Calc.Parser.tokenize("asdf + 43")
     {:error, "Failed to parse token asdf: not a number"}

     iex> Calc.Parser.tokenize("12a + 43")
     {:error, "Failed to parse token 12a: extra chars"}
  """
  def tokenize(exp) do
    exp
    |> to_charlist
    |> split([])
    |> numify([])
  end

  defp split([], acc), do: acc
  defp split([?\s | tail], acc), do: split(tail, acc)
  defp split([?+ | tail], acc), do: split(tail, [:add | acc])
  defp split([?- | tail], acc), do: split(tail, [:sub | acc])
  defp split([?/ | tail], acc), do: split(tail, [:div | acc])
  defp split([?* | tail], acc), do: split(tail, [:mul | acc])

  defp split([ch | tail], [prev | acc]) when is_list(prev) do
    split(tail, [[ch | prev] | acc])
  end

  defp split([ch | tail], acc), do: split(tail, [[ch] | acc])

  defp numify([], acc), do: {:ok, acc}
  defp numify([op | tail], acc) when is_op(op), do: numify(tail, [op | acc])

  defp numify([list | tail], acc) when is_list(list) do
    token =
      list
      |> Enum.reverse()
      |> to_string()

    case Float.parse(token) do
      {n, ""} -> numify(tail, [n | acc])
      {_, _} -> {:error, "Failed to parse token #{token}: extra chars"}
      _ -> {:error, "Failed to parse token #{token}: not a number"}
    end
  end

  @doc """
  Constructs a operation tree from list with tokens
  """
  def build_tree(tokens), do: build_tree(tokens, [])

  defp build_tree([n], []), do: {n}
end
