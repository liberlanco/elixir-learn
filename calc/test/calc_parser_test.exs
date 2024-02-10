defmodule CalcParserTest do
  use ExUnit.Case
  doctest Calc.Parser

  test "tokenize should parse strings" do
    assert Calc.Parser.tokenize("1+2") == {:ok, [1, :add, 2]}
    assert Calc.Parser.tokenize("1 +    2") == {:ok, [1, :add, 2]}
    assert Calc.Parser.tokenize("1 + 2e") == {:error, "failed to parse token 2e: extra chars"}
    assert Calc.Parser.tokenize("1.5-2.6") == {:ok, [1.5, :sub, 2.6]}
    assert Calc.Parser.tokenize("1*2/2") == {:ok, [1, :mul, 2, :div, 2]}
    assert Calc.Parser.tokenize("-2+2") == {:ok, [:sub, 2, :add, 2]}
  end
end
