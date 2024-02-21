defmodule Worker do
  @moduledoc """
  Worker that works until state is good. Worker uses some number as it's state.

  State is good when rem(received number, state) is not 0. 1000 is always
  a good state, since received number can not be greater then 999
  (hardcoded in RequestEmitter)

  Any lower number is a bad state since from time to time it
  can produce reminder == 0

  ### Configuration

  @bad_state_divier - bad state is intruduced when
  incoming NUM is divided by this number

  @bad_state_range - this range defines bad state limits
  """
  use GenServer

  @bad_state_divider 50
  @bad_state_range 10..30

  def start(_) do
    GenServer.start(__MODULE__, {})
  end

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_) do
    GenServer.start_link(__MODULE__, {})
  end

  @doc """
  Call given worker with given number.

  Responds {:ok, result} if number is processed correctly
  """
  @spec call(pid(), integer()) :: :ok
  def call(pid, num) when is_integer(num) do
    GenServer.call(pid, {:num, num})
  end

  # Server (callbacks)

  @impl true
  def init(_) do
    :ok = RequestEmitter.register(self())
    {:ok, 1000}
  end

  @impl true
  def handle_call({:num, num}, _from, state) do
    {:ok, ans, new_state} = process(num, state)
    {:reply, {:ok, ans}, new_state}
  end

  # Clause to introduce bad state
  defp process(num, _) when rem(num, @bad_state_divider) == 0 do
    first..last = @bad_state_range
    {:ok, 1, :rand.uniform(last - first) + first}
  end

  # Normal workflow
  defp process(num, divider) do
    reminder = rem(trunc(num), trunc(divider))
    {:ok, num / reminder, divider}
  end
end
