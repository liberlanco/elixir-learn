defmodule CalcLogicTest do
  use ExUnit.Case
  doctest Calc.Logic

  test "priorities and parentheses" do
    assert Calc.eval("2+2*2") == {:ok, 6}
    assert Calc.eval("2*2+2") == {:ok, 6}
    assert Calc.eval("2*(2+2)") == {:ok, 8}
    assert Calc.eval("(2+2)*2") == {:ok, 8}

    assert Calc.eval("1-2+3") == {:ok, 2}
    assert Calc.eval("1+2-4") == {:ok, -1}
    assert Calc.eval("(1-2)+3") == {:ok, 2}
    assert Calc.eval("(1+2)-4") == {:ok, -1}
    assert Calc.eval("1-(2+3)") == {:ok, -4}
    assert Calc.eval("1+(2-4)") == {:ok, -1}
  end

  test "negative numbers" do
    assert Calc.eval("-1+4") == {:ok, 3}
    assert Calc.eval("-1+-4") == {:ok, -5}
    assert Calc.eval("1+-4") == {:ok, -3}
    assert Calc.eval("1--(2+3)") == {:ok, 6}
    assert Calc.eval("-1--(-2--3)") == {:ok, 0}
  end

  test "strange but possible" do
    assert Calc.eval("(((((((2)))))))") == {:ok, 2}
    assert Calc.eval("(((((((2+2)))))))") == {:ok, 4}
    assert Calc.eval("----------1") == {:ok, 1}
  end

  test "error handling" do
    assert Calc.eval("+2") == {:error, "unexpected token: add"}
    assert Calc.eval("2+") == {:error, "missing argument"}
    assert Calc.eval("2-+4") == {:error, "unexpected token: add"}
    assert Calc.eval("2++") == {:error, "unexpected token: add"}
    assert Calc.eval("2+2=4") == {:error, "failed to parse token 2=4: extra chars"}
    assert Calc.eval("1+(2+3))") == {:error, "unexpected token: rparen"}
    assert Calc.eval("(1+(2+3)") == {:error, "missing closing bracket"}
    assert Calc.eval("1+(/2+3)") == {:error, "unexpected token: div"}
  end
end
