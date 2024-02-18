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
    {:ok, %{list: PidsList.new(), refs: %{}}}
  end

  @impl true
  def handle_cast({:register, pid}, state) do
    Logger.info("Register #{inspect(pid)}")

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
        {:ok, task_pid} = Task.start(fn -> emit(pid) end)
        ref = Process.monitor(task_pid)

        {:noreply, %{state | refs: Map.put(state.refs, ref, pid)}}

      {:error, :empty_list} ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, :normal}, state) do
    {:noreply, %{state | refs: Map.delete(state.refs, ref)}}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    pid = Map.get(state.refs, ref)
    Logger.info("Forget #{inspect(pid)}. Call to this worker died.")

    new_state = %{
      state
      | refs: Map.delete(state.refs, ref),
        list: PidsList.remove(state.list, pid)
    }

    {:noreply, new_state}
  end

  @impl true
  def handle_info(info, state) do
    IO.puts(info)
    {:noreply, state}
  end

  defp emit(pid) do
    num = :rand.uniform(999)
    IO.puts("send #{num} to #{inspect(pid)} from #{inspect(self())}")
    Worker.call(pid, num)
  end
end
