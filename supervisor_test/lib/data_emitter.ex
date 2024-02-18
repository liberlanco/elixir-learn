defmodule DataEmitter do
  @moduledoc false
  use GenServer

  require Logger

  @interval 100
  @name {:global, __MODULE__}

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def register(pid) when is_pid(pid) do
    GenServer.cast(@name, {:register, pid})
  end

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
        # Not start_link because don't want to die, if task
        # failed to do Worker.call for any reason
        Task.start(fn -> emit(pid) end)
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

  defp emit(pid) do
    num = :rand.uniform(999)
    # Logger.debug("send #{num} to #{inspect(pid)} from #{inspect(self())}")
    Worker.call(pid, num)
  end
end
