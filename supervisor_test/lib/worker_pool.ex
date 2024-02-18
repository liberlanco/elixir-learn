defmodule WorkerPool do
  use Supervisor

  def start_link(opts) do
    IO.puts(inspect(opts))
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(num) do
    base_child_spec = Worker.child_spec({})

    children =
      1..num
      |> Enum.map(fn i -> %{base_child_spec | id: String.to_atom("worker_#{i}")} end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
