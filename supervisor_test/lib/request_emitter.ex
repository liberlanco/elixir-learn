defmodule RequestEmitter do
  @moduledoc """
  Emulatore of client requests.

  Each request is a random number in `@request_num_range`.

  Each `@interval` milliseconds `RequestEmitter` sends random request to
  random worker.

  ### Configuration

  @interval - how often to send requests

  @raquest_num_range - range for outgoing request number

  """
  use GenServer
  @name {:global, __MODULE__}

  require Logger

  @interval 100
  @request_num_range 1..999

  # Client

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  @doc """
  Registers given `pid` in internal list of pids.

  Returns :ok in any case, even if pid already registered
  """
  @spec register(pid()) :: :ok
  def register(pid) when is_pid(pid) do
    GenServer.cast(@name, {:register, pid})
  end

  @doc """
  Unregisters given `pid`

  Returns :ok in any case, even if pid is already unregistered
  """
  @spec unregister(pid()) :: :ok
  def unregister(pid) when is_pid(pid) do
    GenServer.cast(@name, {:unregister, pid})
  end

  # Server (callbacks)

  @impl true
  def init(_) do
    :timer.send_interval(@interval, :emit)
    {:ok, %{list: PidsList.new()}}
  end

  @impl true
  def handle_cast({:register, pid}, state) do
    Logger.info("Register #{inspect(pid)}")
    Process.monitor(pid)
    {:noreply, %{state | list: PidsList.add(state.list, pid)}}
  end

  @impl true
  def handle_cast({:unregister, pid}, state) do
    Logger.info("Unregister #{inspect(pid)}")
    {:noreply, %{state | list: PidsList.remove(state.list, pid)}}
  end

  @impl true
  def handle_info(:emit, state) do
    case PidsList.random_pid(state.list) do
      {:ok, pid} ->
        # Should not die because of any problems in this task
        Task.Supervisor.start_child(RequestTasksSup, fn -> emit(pid) end)
        {:noreply, state}

      {:error, :empty_list} ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    Logger.info("Forget #{inspect(pid)}. Worker died.")
    {:noreply, %{state | list: PidsList.remove(state.list, pid)}}
  end

  # Emit request body. Isolated in Task process
  defp emit(pid) do
    first..last = @request_num_range
    num = :rand.uniform(last - first) + first
    Logger.debug("send #{num} to #{inspect(pid)} from #{inspect(self())}")
    Worker.call(pid, num)
  end
end
