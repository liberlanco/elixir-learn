defmodule SupervisorTestTest do
  use ExUnit.Case
  doctest SupervisorTest

  test "greets the world" do
    assert SupervisorTest.hello() == :world
  end
end
