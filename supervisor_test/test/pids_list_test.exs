defmodule PidsListTest do
  use ExUnit.Case
  doctest PidsList

  test "full workflow" do
    pid1 = spawn(fn -> :ok end)
    pid2 = spawn(fn -> :ok end)
    pid3 = spawn(fn -> :ok end)

    list =
      PidsList.new()
      |> PidsList.add(pid1)
      |> PidsList.add(pid2)
      |> PidsList.add(pid3)

    assert !!list == true

    {:ok, ans} = PidsList.random_pid(list)
    assert ans in [pid1, pid2, pid3]
  end
end
