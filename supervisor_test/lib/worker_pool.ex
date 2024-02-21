defmodule WorkerPool do
  @moduledoc """
  Workers supervisor.

  ### Configuration
  @max_restarts - How many restarts (any child?) is allowed during @max_seconds

  @max_seconds - How long to calculate restarts
  """
  use Supervisor

  @max_restarts 3
  @max_seconds 5

  def start_link(count) do
    Supervisor.start_link(__MODULE__, count, name: __MODULE__)
  end

  @impl true
  def init(count) do
    children =
      1..count
      |> Enum.map(fn i ->
        Supervisor.child_spec({Worker, {}}, id: {Worker, i})
      end)

    Supervisor.init(children,
      strategy: :one_for_one,
      max_restarts: @max_restarts,
      max_seconds: @max_seconds
    )
  end
end
