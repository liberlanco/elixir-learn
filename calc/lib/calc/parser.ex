defmodule Calc.Parser do
  @moduledoc """
  Module with functions to parse given expression into evaluation tree
  """

  defguardp is_op(op) when is_atom(op) and op in [:add, :mul, :div, :sub]

  @doc """
  Parses given string with expression and returns operation tree

  ### Examples

      iex>  Calc.Parser.parse("2 * 3 + 4")
      {:ok, {:node, {:node, {:num, 2.0}, :mul, {:num, 3.0}}, :add, {:num, 4.0}}}
  """
  def parse(exp) do
    with {:ok, tokens} <- tokenize(exp),
         {:ok, tree} <- build_tree(tokens, []) do
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

  defguardp is_node(tuple) when elem(tuple, 0) == :node
  defguardp is_op_node(tuple) when elem(tuple, 0) == :op
  defguardp is_num_node(tuple) when elem(tuple, 0) == :num
  defguardp is_arg_node(x) when is_node(x) or is_num_node(x)

  # Input: tokenized string
  # Output:  Tree of nodes
  # Example:
  #    Calc.Parser.build_tree([123.0, :add, 1.2, :sub, 10.0], [])
  # Output:
  #  {:ok,
  #    {:node,
  #      {:node,
  #        {:num, 123.0},
  #        :add,
  #        {:num, 1.2}
  #      },
  #      :sub,
  #      {:num, 10.0}
  #    }
  #  }
  #
  defp build_tree([], [arg]) when is_arg_node(arg), do: {:ok, arg}
  defp build_tree([], []), do: {:ok, {:num, 0.0}}
  defp build_tree([], _), do: {:error, "not complete expression"}

  defp build_tree([head | tail], stack) do
    node = to_node(head)

    with {:ok, new_stack} <- push(node, stack) do
      build_tree(tail, new_stack)
    end
  end

  defp to_node(num) when is_float(num), do: {:num, num}
  defp to_node(op) when is_op(op), do: {:op, op}

  defp push(num, []) when is_num_node(num), do: {:ok, [num]}
  defp push(op, []) when is_op_node(op), do: {:error, "Unexpected operand #{op}"}

  defp push(op, stack) when is_op_node(op), do: {:ok, [op | stack]}

  defp push(right, [{:op, op}, left | tail])
       when is_arg_node(right) and is_arg_node(left) do
    {:ok, [{:node, left, op, right} | tail]}
  end

  defp push(token, _) do
    str = token |> Tuple.to_list() |> Enum.join(", ")
    {:error, "Unexpected token { #{str} }"}
  end
end
