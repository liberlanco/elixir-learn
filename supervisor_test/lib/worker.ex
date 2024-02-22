defmodule Worker do
  @moduledoc """
  Worker that works until state is good. Worker uses some number as it's state.

  State is good when rem(received number, state) is not 0. 1000 is always
  a good state, since received number can not be greater then 999
  (hardcoded in RequestEmitter)

  Any lower number is a bad state since from time to time it
  can produce reminder == 0

  ### Configuration

  worker_bad_state_divier - bad state is intruduced when
  incoming NUM is divided by this number

  worker_bad_state_range - this range defines bad state limits
  """
  use GenServer

  @bad_state_divider Application.compile_env!(:supervisor_test_app, :worker_bad_state_divider)
  @bad_state_range Application.compile_env!(:supervisor_test_app, :worker_bad_state_range)

  def start(options) do
    init_arg = parse_options(options)
    GenServer.start(__MODULE__, init_arg)
  end

  def start_link(options) do
    init_arg = parse_options(options)
    GenServer.start_link(__MODULE__, init_arg)
  end

  @doc """
  Call given worker with given number.

  Responds {:ok, result} if number is processed correctly
  """
  @spec call(pid(), integer()) :: :ok
  def call(pid, num) when is_integer(num) do
    GenServer.call(pid, {:call, num})
  end

  # Server (callbacks)

  @impl true
  def init({state}) do
    Registry.register(WorkerRegistry, :worker, [])
    {:ok, state}
  end

  @impl true
  def handle_call({:call, num}, _from, state) do
    {ans, new_state} = process(num, state)
    {:reply, {:ok, ans}, new_state}
  end

  # Clause to introduce bad state
  defp process(num, _) when rem(num, @bad_state_divider) == 0 do
    first..last = @bad_state_range
    {1, :rand.uniform(last - first) + first}
  end

  # Normal workflow
  defp process(num, divider) do
    reminder = rem(trunc(num), trunc(divider))
    {num / reminder, divider}
  end

  defp parse_options(options) do
    state =
      case Keyword.get(options, :state, 1000) do
        n when is_integer(n) and n > 0 -> n
        _ -> raise ArgumentError, "expected positive integer as state"
      end

    {state}
  end
end
