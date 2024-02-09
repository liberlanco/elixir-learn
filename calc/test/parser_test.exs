defmodule CalcParserTest do
  use ExUnit.Case
  doctest Calc.Parser

  test "tokenize should parse strings" do
    assert Calc.Parser.tokenize("1+2") == {:ok, [1.0, :add, 2.0]}
    assert Calc.Parser.tokenize("1 +    2") == {:ok, [1.0, :add, 2.0]}
    assert Calc.Parser.tokenize("1.0 + 2e") == {:error, "failed to parse token 2e: extra chars"}
    assert Calc.Parser.tokenize("1-2") == {:ok, [1.0, :sub, 2.0]}
    assert Calc.Parser.tokenize("1*2/2") == {:ok, [1.0, :mul, 2.0, :div, 2.0]}
    assert Calc.Parser.tokenize("-2+2") == {:ok, [:sub, 2.0, :add, 2.0]}
  end
end
