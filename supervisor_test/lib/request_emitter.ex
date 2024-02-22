defmodule RequestEmitter do
  @moduledoc """
  Emulate client's requests.

  Each request is a random number in `@request_num_range`.

  Each `@interval` milliseconds `RequestEmitter` sends random request to
  random worker.

  ### Configuration

  @interval - how often to send requests

  @request_num_range - range for outgoing request number

  """
  use GenServer
  @name {:global, __MODULE__}

  require Logger

  @interval Application.compile_env!(:supervisor_test_app, :request_interval)
  @request_num_range Application.compile_env!(:supervisor_test_app, :request_num_range)
  @enabled Application.compile_env!(:supervisor_test_app, :emitter_enabled)

  # Client

  @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(options) do
    enabled = Keyword.get(options, :enabled, @enabled)
    GenServer.start_link(__MODULE__, {enabled}, name: @name)
  end

  @doc """
  Start sending requests to all registered workers
  """
  @spec enable() :: :ok
  def enable do
    GenServer.cast(@name, :enable)
  end

  @doc """
  Stop sending requests
  """
  @spec disable() :: :ok
  def disable do
    GenServer.cast(@name, :disable)
  end

  @doc """
  Get status of the emitter
  """
  @spec status() :: boolean()
  def status do
    GenServer.call(@name, :status)
  end

  # Server (callbacks)

  @impl true
  def init({enabled}) do
    :timer.send_interval(@interval, :emit)
    {:ok, %{enabled: enabled}}
  end

  @impl true
  def handle_cast(:enable, state) do
    Logger.info("Emitter enabled")
    {:noreply, %{state | enabled: true}}
  end

  @impl true
  def handle_cast(:disable, state) do
    Logger.info("Emitter disabled")
    {:noreply, %{state | enabled: false}}
  end

  @impl true
  def handle_call(:status, _from, state) do
    {:reply, state.enabled, state}
  end

  @impl true
  def handle_info(:emit, %{enabled: false} = state) do
    {:noreply, state}
  end

  def handle_info(:emit, state) do
    pids =
      Registry.lookup(WorkerRegistry, :worker)
      |> Enum.map(fn {pid, _} -> pid end)

    case pids do
      [] ->
        {:noreply, state}

      pids ->
        pid = Enum.random(pids)
        Task.Supervisor.start_child(RequestTasksSup, fn -> emit(pid) end)
        {:noreply, state}
    end
  end

  # Emits request. Isolated in Task process
  defp emit(pid) do
    first..last = @request_num_range
    num = :rand.uniform(last - first) + first
    Logger.debug("send #{num} to #{inspect(pid)} from #{inspect(self())}")
    Worker.call(pid, num)
  end
end
