defmodule RequestEmitterTest do
  use ExUnit.Case

  setup do
    on_exit(fn ->
      RequestEmitter.disable()
    end)
  end

  test "normal emitting" do
    Registry.register(WorkerRegistry, :worker, [])
    RequestEmitter.enable()
    assert_receive {:"$gen_call", _pid, {:call, _}}, 1000
  end
end
