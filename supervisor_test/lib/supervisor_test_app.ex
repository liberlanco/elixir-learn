defmodule SupervisorTestApp do
  @moduledoc """
  Supervisor test application.

  It starts `RequestEmitter` as clients emulation, and then it starts `WorkerPool`
  supervisor with some count of `Worker`-s. Workers automatically register in
  `RequestEmitter` and start process requests.

  With some random time some workers should die, supervisor should restart them
  or restart itself. Application should survive.
  """
  use Application

  @workers_count Application.compile_env!(:supervisor_test_app, :workers_count)

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: RequestTasksSup},
      {Registry, name: WorkerRegistry, keys: :duplicate},
      RequestEmitter,
      {WorkerPool, @workers_count}
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: SupervisorTestApp
    )
  end
end
