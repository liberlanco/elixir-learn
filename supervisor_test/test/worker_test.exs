defmodule WorkerTest do
  use ExUnit.Case

  @fail_range Application.compile_env!(:supervisor_test_app, :worker_bad_state_range)
  @fail_num Application.compile_env!(:supervisor_test_app, :worker_bad_state_divider)
  @resp_range Application.compile_env!(:supervisor_test_app, :request_num_range)

  # prime number, doesn't have dividers
  @good_num 13

  # Backup and restore Logger.level, since it's manipulated
  setup do
    current_logger_level = Logger.level()

    on_exit(fn ->
      Logger.configure(level: current_logger_level)
    end)
  end

  test "Worker normal workflow" do
    {:ok, pid} = Worker.start_link([])
    {:ok, response} = Worker.call(pid, @good_num)
    assert trunc(response) in @resp_range
  end

  test "Worker crash workflow" do
    {:ok, pid} = Worker.start([])
    ref = Process.monitor(pid)

    {:ok, response} = Worker.call(pid, @fail_num)
    assert response == 1

    Logger.configure(level: :alert)
    # Spam with numbers in fail state range, should cause failure
    Task.start(fn ->
      Enum.map(@fail_range, fn num -> Worker.call(pid, num) end)
    end)

    assert_receive {:DOWN, ^ref, :process, ^pid, _reason}, 1000
  end
end
