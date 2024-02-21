defmodule RequestEmitterTest do
  use ExUnit.Case

  setup do
    {:ok, pid1} = RequestEmitter.start_link({})
    {:ok, pid2} = Task.Supervisor.start_link(name: RequestTasksSup)

    on_exit(fn ->
      Process.exit(pid1, :kill)
      Process.exit(pid2, :kill)
    end)
  end

  test "normal emitting" do
    RequestEmitter.register(self())

    # Wanted to test that RequestEmitter really sends events
    # but looks like this architecture ended in low-level hack in tests,
    # Probably, I should use handle_info instead of handle_call if
    # I want to test such interop in future, but not sure.
    assert_receive {:"$gen_call", _pid, {:num, _}}, 1000
  end

  test "bad arguments" do
    assert_raise FunctionClauseError, fn -> RequestEmitter.register(12) end
    assert_raise FunctionClauseError, fn -> RequestEmitter.register(:atom) end
    assert_raise FunctionClauseError, fn -> RequestEmitter.register("worker 1") end
  end
end
