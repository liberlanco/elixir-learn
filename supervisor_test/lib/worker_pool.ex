defmodule WorkerPool do
  use Supervisor

  @max_restarts 3
  @max_seconds 5

  def start_link(opts) do
    IO.puts(inspect(opts))
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(num) do
    children =
      1..num
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
