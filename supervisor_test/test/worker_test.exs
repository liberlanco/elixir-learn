defmodule WorkerTest do
  use ExUnit.Case

  test "Worker normal workflow" do
    {:ok, pid} = Worker.start_link({})
    {:ok, response} = Worker.call(pid, 13)
    assert trunc(response) in 1..1000
  end

  # Don't like this test, becaue it generates
  # error crash dumps. Also, it's not good
  # to hide those crash dumps or to increase logger level
  # to :alert, because it can hide other important
  # log messages.
  # Alternative is to make Worker.process public function,
  # but this is not good too.
  # May be I just should not test those process crash scenarious
  # because it should not be tested expected way in normal app.
  test "Worker crash workflow" do
    {:ok, pid} = Worker.start({})
    ref = Process.monitor(pid)

    # Cause failure state
    {:ok, response} = Worker.call(pid, 100)
    assert response == 1

    # Spam with numbers, should cause failure
    Task.start(fn ->
      Enum.map(1..100, fn num -> Worker.call(pid, num) end)
    end)

    assert_receive {:DOWN, ^ref, :process, ^pid, _reason}, 1000
  end
end
