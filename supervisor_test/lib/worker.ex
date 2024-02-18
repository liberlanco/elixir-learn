defmodule Worker do
  @moduledoc """
  Worker that works until state is good.

  State is good when rem(received number, state) is not 0.

  1000 is always a good state, since received number
  can not be greater then 999 (hardcoded in DataEmitter)

  Any lower number is a bad state since from time to time it can produce reminder == 0
  """

  use GenServer

  def start(_) do
    GenServer.start(__MODULE__, {})
  end

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  @doc """
  Start worker process
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, {})
  end

  @spec call(pid(), integer()) :: :ok
  @doc """
  Process given number. Send it and pray.
  """
  def call(pid, num) when is_integer(num) do
    GenServer.call(pid, {:num, num})
  end

  # Server (callbacks)

  @impl true
  def init(_) do
    :ok = DataEmitter.register(self())
    {:ok, 1000}
  end

  @impl true
  def handle_call({:num, num}, _from, state) do
    {:reply, :ok, process(num, state)}
  end

  # Introduce bad state
  defp process(num, _) when rem(num, 100) == 0 do
    :rand.uniform(10) + 10
  end

  # Normal workflow
  defp process(num, state) do
    false = rem(num, state) == 0
    state
  end
end
