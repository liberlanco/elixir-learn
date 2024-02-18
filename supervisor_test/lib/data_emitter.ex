defmodule DataEmitter do
  @moduledoc false
  use GenServer

  # @interval 200
  @name {:global, __MODULE__}

  # Client

  def start_link(%{}) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def register(pid) do
    GenServer.cast(@name, {:register, pid})
  end

  # Server (callbacks)

  @impl true
  def init(_data) do
    {:ok, %{pids: %{}}}
  end

  @impl true
  def handle_cast({:register, _pid}, state) do
    {:noreply, state}
  end
end
