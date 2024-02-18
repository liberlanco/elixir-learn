defmodule PidsList do
  @doc """
  Structure to hide details about how pids are stored, managed
  and how random pid is generated

  I don't that it's really needed to have such struct in this case
  but wanted to experiment with this approach. How easy to do such
  incapsulations

  ### Example

      iex> pid1 = :erlang.list_to_pid('<0.1.2>')
      #PID<0.1.2>
      iex> list = PidsList.new()
      %PidsList{pids: %{}}
      iex> list = PidsList.add(list, pid1)
      iex> {:ok, ans} = PidsList.random_pid(list)
      iex> ans
      #PID<0.1.2>

      iex> PidsList.random_pid(PidsList.new())
      {:error, :empty_list}

  """
  defstruct pids: %{}

  @type t :: %__MODULE__{
          pids: %{pid => boolean}
        }

  @spec new() :: PidsList.t()
  @doc """
  Create new pids list
  """
  def new() do
    %__MODULE__{}
  end

  @spec add(PidsList.t(), pid()) :: PidsList.t()
  @doc """
  Add new pid to pid list, it should be silent, if pid already exists there
  """
  def add(%__MODULE__{} = list, pid) do
    %__MODULE__{list | pids: Map.put(list.pids, pid, true)}
  end

  @spec remove(PidsList.t(), pid()) :: PidsList.t()
  @doc """
  Remove pid from pid list. Do nothing if pid is missing
  """
  def remove(%__MODULE__{} = list, pid) do
    %__MODULE__{list | pids: Map.delete(list.pids, pid)}
  end

  @spec random_pid(PidsList.t()) :: {:error, :empty_list} | {:ok, pid()}
  @doc """
  Return random pid from the list
  """
  def random_pid(%__MODULE__{pids: pids}) when map_size(pids) == 0, do: {:error, :empty_list}

  def random_pid(%__MODULE__{pids: pids}) do
    {pid, _} = Enum.random(pids)
    {:ok, pid}
  end
end
