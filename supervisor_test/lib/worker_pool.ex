defmodule WorkerPool do
  @moduledoc """
  Workers supervisor.

  ### Configuration
  worker_sup_max_restarts - How many restarts (any child?) is allowed during @max_seconds

  worker_sup_max_seconds - How long to calculate restarts
  """
  use Supervisor

  @max_restarts Application.compile_env!(:supervisor_test_app, :worker_sup_max_restarts)
  @max_seconds Application.compile_env!(:supervisor_test_app, :worker_sup_max_seconds)
  @worker_init_state Application.compile_env!(:supervisor_test_app, :worker_init_state)

  def start_link(count) do
    Supervisor.start_link(__MODULE__, count, name: __MODULE__)
  end

  @impl true
  @spec init(integer()) :: {:ok, {map(), list()}}
  def init(count) do
    children =
      1..count
      |> Enum.map(fn i ->
        Supervisor.child_spec({Worker, [state: @worker_init_state]}, id: {Worker, i})
      end)

    Supervisor.init(children,
      strategy: :one_for_one,
      max_restarts: @max_restarts,
      max_seconds: @max_seconds
    )
  end
end
