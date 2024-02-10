defmodule Calc.Parser do
  @moduledoc """
  Module with functions to parse given expression into evaluation tree
  """

  defguardp is_op(op) when is_atom(op) and op in [:add, :mul, :div, :sub, :lparen, :rparen]

  @doc """
  Parses given string with expression and returns operation tree

  ### Examples

      iex>  Calc.Parser.parse("2 * 3 + 4")
      {:ok, {:add, {:mul, {:num, 2.0}, {:num, 3.0}}, {:num, 4.0}}}

      iex(3)> Calc.Parser.parse("-2 + 3 / 4")
      {:ok, {:add, {:neg, {:num, 2.0}}, {:div, {:num, 3.0}, {:num, 4.0}}}}

  """
  def parse(exp) do
    with {:ok, tokens} <- tokenize(exp),
         {:ok, tree} <- rd_parser(tokens) do
      {:ok, tree}
    end
  end

  @doc """
  Tokenize given string, convert all numbers to floats

  ### Examples

      iex> Calc.Parser.tokenize("14 + 21 - 13 + 43 * 55")
      {:ok, [14.0, :add, 21.0, :sub, 13.0, :add, 43.0, :mul, 55.0]}

      iex> Calc.Parser.tokenize("asdf + 43")
      {:error, "failed to parse token asdf: not a number"}

      iex> Calc.Parser.tokenize("12a + 43")
      {:error, "failed to parse token 12a: extra chars"}
  """
  def tokenize(exp) do
    exp
    |> to_charlist
    |> split([])
    |> reverse_and_convert([])
  end

  # Splits given iolist to tokens
  # Returns reversed list of tokens, and each "string" in that list
  # is also reversed. Need to pass thru reverse_and_convert fo final result
  defp split([], acc), do: acc
  defp split([?\s | tail], acc), do: split(tail, acc)
  defp split([?+ | tail], acc), do: split(tail, [:add | acc])
  defp split([?- | tail], acc), do: split(tail, [:sub | acc])
  defp split([?/ | tail], acc), do: split(tail, [:div | acc])
  defp split([?* | tail], acc), do: split(tail, [:mul | acc])
  defp split([?\( | tail], acc), do: split(tail, [:lparen | acc])
  defp split([?\) | tail], acc), do: split(tail, [:rparen | acc])

  defp split([ch | tail], [prev | acc]) when is_list(prev) do
    split(tail, [[ch | prev] | acc])
  end

  defp split([ch | tail], acc), do: split(tail, [[ch] | acc])

  # Second step of tokenize workflow.
  # It reverses output of split, and at the same time
  # Reverses each token inside and converts it to float
  defp reverse_and_convert([], acc), do: {:ok, acc}

  defp reverse_and_convert([op | tail], acc) when is_op(op),
    do: reverse_and_convert(tail, [op | acc])

  defp reverse_and_convert([list | tail], acc) when is_list(list) do
    token =
      list
      |> Enum.reverse()
      |> to_string()

    case Float.parse(token) do
      {n, ""} -> reverse_and_convert(tail, [n | acc])
      {_, _} -> {:error, "failed to parse token #{token}: extra chars"}
      _ -> {:error, "failed to parse token #{token}: not a number"}
    end
  end

  # Recursive Descending Parser as here: https://www.youtube.com/watch?v=SToUyjAsaFk
  # but in functional language
  #
  # Main rules:
  #  E -> T {+- T} | T
  #  T -> F {*/ F} | F
  #  F -> number | ( E ) | -F

  def rd_parser(tokens) do
    case exp(tokens) do
      {:ok, tree, []} -> {:ok, tree}
      {:ok, _, tail} -> {:error, "unexpected token: #{Enum.at(tail, 0)}"}
      err -> err
    end
  end

  defp factor([n | tail]) when is_number(n), do: {:ok, {:num, n}, tail}

  defp factor([:sub | tail]) do
    case factor(tail) do
      {:ok, a, new_tail} -> {:ok, {:neg, a}, new_tail}
      err -> err
    end
  end

  defp factor([:lparen | tail]) do
    case exp(tail) do
      {:ok, res, [:rparen | new_tail]} -> {:ok, res, new_tail}
      {:ok, _, _} -> {:error, "missing closing bracket"}
      err -> err
    end
  end

  defp factor([a | _]), do: {:error, "unexpected token: #{a}"}
  defp factor([]), do: {:error, "missing argument"}

  defp term(tokens) do
    case factor(tokens) do
      {:ok, a, tail} -> term(a, tail)
      err -> err
    end
  end

  defp term(a, [op | tail]) when op in [:mul, :div] do
    case factor(tail) do
      {:ok, b, new_tail} ->
        new_a = {op, a, b}
        term(new_a, new_tail)

      err ->
        err
    end
  end

  defp term(a, tokens), do: {:ok, a, tokens}

  defp exp(tokens) do
    case term(tokens) do
      {:ok, a, tail} -> exp(a, tail)
      err -> err
    end
  end

  defp exp(a, [op | tail]) when op in [:add, :sub] do
    case term(tail) do
      {:ok, b, new_tail} ->
        new_a = {op, a, b}
        exp(new_a, new_tail)

      err ->
        err
    end
  end

  defp exp(a, tokens), do: {:ok, a, tokens}
end
