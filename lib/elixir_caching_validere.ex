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

  def init(name, size, opts \\ []) do
    ttl_table = :"#{name}_ttl"
    :ets.new(ttl_table, [:named_table, :ordered_set])
    :ets.new(name, [:named_table, :public, {:read_concurrency, true}])
    evict_fn = Keyword.get(opts, :evict_fn)
    %ElixirCachingValidere{ttl_table: ttl_table, table: name, size: size, evict_fn: evict_fn}
  end

  def put(name, key, value),
    do: Agent.get(name, __MODULE__, :handle_put, [key, value])

  def handle_put(state = %{table: table}, key, value) do
    delete_ttl(state, key)
    uniq = insert_ttl(state, key)
    :ets.insert(table, {key, uniq, value})
    clean_oversize(state)
    :ok
  end

  defp delete_ttl(%{ttl_table: ttl_table, table: table}, key) do
    case :ets.lookup(table, key) do
      [{_, old_uniq, _}] ->
        :ets.delete(ttl_table, old_uniq)

      _ ->
        nil
    end
  end

  defp insert_ttl(%{ttl_table: ttl_table}, key) do
    uniq = :erlang.unique_integer([:monotonic])
    :ets.insert(ttl_table, {uniq, key})
    uniq
  end

  defp clean_oversize(state = %{ttl_table: ttl_table, table: table, size: size}) do
    if :ets.info(table, :size) > size do
      oldest_tstamp = :ets.first(ttl_table)
      [{_, old_key}] = :ets.lookup(ttl_table, oldest_tstamp)
      :ets.delete(ttl_table, oldest_tstamp)
      call_evict_fn(state, old_key)
      :ets.delete(table, old_key)
      true
    else
      nil
    end
  end

  defp call_evict_fn(%{evict_fn: nil}, _old_key), do: nil

  defp call_evict_fn(%{evict_fn: evict_fn, table: table}, key) do
    [{_, _, value}] = :ets.lookup(table, key)
    evict_fn.(key, value)
  end


  def hello do
    :world
  end
end
