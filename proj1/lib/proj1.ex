defmodule Proj1 do
  @moduledoc """
  Documentation for `Proj1`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Proj1.hello(%{name: "John"})
      "Hello, John!"

      iex> Proj1.hello(%{alias: "John"})
      "Hello, Anonym!"

      iex> Proj1.hello(nil)
      ** (FunctionClauseError) no function clause matching in Proj1.hello/1


  """

  @spec hello(map()) :: String.t()
  def hello(%{} = map) do
    map
    |> Map.fetch(:name)
    |> resolve()
  end

  defp resolve(:error), do: "Hello, Anonym!"
  defp resolve({:ok, name}), do: "Hello, #{name}!"
end
