defmodule CalcTest do
  use ExUnit.Case
  doctest Calc

  test "tokenize should parse strings" do
    assert Calc.Parser.tokenize("1+2") == ["1", :add, "2"]
    assert Calc.Parser.tokenize("1 +    2") == ["1", :add, "2"]
    assert Calc.Parser.tokenize("1.0 + 2e") == ["1.0", :add, "2e"]
    assert Calc.Parser.tokenize("1-2") == ["1", :sub, "2"]
    assert Calc.Parser.tokenize("1*2/2") == ["1", :mul, "2", :div, "2"]
    assert Calc.Parser.tokenize("-2+2") == [:sub, "2", :add, "2"]
  end
end
