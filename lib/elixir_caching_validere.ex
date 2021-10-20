defmodule ElixirCachingValidere do
  @moduledoc """
  Documentation for `ElixirCachingValidere`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ElixirCachingValidere.hello()
      :world

  """

  use GenServer

  defstruct table: nil, ttl_table: nil, size: 0, evict_fn: nil

  def start_link(name, size, opts \\ []) do
    Agent.start_link(__MODULE__, :init, [name, size, opts], name: name)
  end


  def hello do
    :world
  end
end
