defmodule SupervisorTestApp do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DataEmitter,
      {WorkerPool, 10}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: SupervisorTestApp)
  end
end
