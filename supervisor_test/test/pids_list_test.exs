defmodule PidsListTest do
  use ExUnit.Case
  doctest PidsList

  test "normal workflow" do
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

    list = PidsList.remove(list, pid1)
    {:ok, ans} = PidsList.random_pid(list)
    assert ans in [pid2, pid3]

    list = PidsList.remove(list, pid2)
    {:ok, ans} = PidsList.random_pid(list)
    assert ans == pid3

    list = PidsList.remove(list, pid3)
    assert PidsList.random_pid(list) == {:error, :empty_list}
  end

  test "double add and double remove" do
    pid1 = spawn(fn -> :ok end)

    list = PidsList.new()

    list = PidsList.add(list, pid1)
    list2 = PidsList.add(list, pid1)
    assert list == list2, "double add should be successful"

    list = PidsList.remove(list, pid1)
    list2 = PidsList.remove(list, pid1)
    assert list == list2, "double remove should be successful"
  end
end
