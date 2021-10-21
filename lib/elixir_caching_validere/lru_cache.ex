defmodule ElixirCachingValidere.LruCache do

  @moduledoc ~S"""
  Using 2 ets tables this module implements the LRU caching logic


  ## Design
  table: for storing the cache values
  time_table: for storing cache items expiration data
  """

  use GenServer

  defstruct table: nil, time_table: nil, size: 0, evict_fn: nil

  @doc """
  Creates an LRU of the given size as part of a supervision tree with a registered name. It starts Agent with :init function as a param and `size` param
  ## Options
    * `:evict_fn` - function that accepts (key, value) and takes some action when keys are
      evicted when the cache is full.
  """

  def start_link(size, opts \\ []) do
    Agent.start_link(__MODULE__, :init, [size, opts], name: :cache)
  end

  def init({size, opts}) do
    init(size, opts)
  end

  @doc """
  Init function initializes two ets tables
  """

  def init(size, opts \\ []) do
    time_table = :cache_timetable
    :ets.new(time_table, [:named_table, :ordered_set])
    :ets.new(:cache, [:named_table, :public, {:read_concurrency, true}])
    evict_fn = Keyword.get(opts, :evict_fn)
    %ElixirCachingValidere.LruCache{time_table: time_table, table: :cache, size: size, evict_fn: evict_fn}
  end

  @doc """
  The function takes two params `key` and `value` and either:
  1. Creates a new entry in the ets table if the `key` does not exist
  2. Updates the `value` if `key` already exists

  This updates the order of the cache with an LRU logic
  """

  def put(key, value),
    do: Agent.get(:cache, __MODULE__, :handle_put, [key, value])

  @doc """
  The function "handles" the put function by doing the following tasks:
  1. Deleting the old time entry from the ets table
  2. Inserting time entry and getting a new position
  3. Inserting the cache entry
  4. Resetting the old values

  returns ok status
  """

  def handle_put(state = %{table: table}, key, value) do
    delete_timetable(state, key)
    uniq = insert_timetable(state, key)
    :ets.insert(table, {key, uniq, value})
    reset_values(state)
    :ok
  end

  # The function gets the position for the item and then deletes it from the ets table

  defp delete_timetable(%{time_table: time_table, table: table}, key) do
    case :ets.lookup(table, key) do
      [{_, old_uniq, _}] ->
        :ets.delete(time_table, old_uniq)

      _ ->
        nil
    end
  end

  # The function inserts an entry in the time_table by doing the following tasks:
  # 1. Getting uniq integer and this integer is always larger than previously returned integers on the current runtime system instance
  # 2. Inserting the entry with the new position on the ets table

  defp insert_timetable(%{time_table: time_table}, key) do
    position = :erlang.unique_integer([:monotonic])
    :ets.insert(time_table, {position, key})
    position
  end

  # This function resets the values in the ets field if the new size of the ets table is larger than the specified size.
  # Tasks performed:
  # 1. Find the oldest timestamp
  # 2. Find item by oldest timestamp
  # 3. Delete oldest item from time_table
  # 4. Delete oldest key from :cache

  defp reset_values(state = %{time_table: time_table, table: table, size: size}) do
    if :ets.info(table, :size) > size do
      oldest_tstamp = :ets.first(time_table)
      [{_, old_key}] = :ets.lookup(time_table, oldest_tstamp)
      :ets.delete(time_table, oldest_tstamp)
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

  @doc """
  This function takes the param `key` and returns either:
  1. The `value` associated with the `key` if the `key` exists in the caching table
  2. nil if the `key` does not exist in the ets table

  param `touch` (default true) defines if the order in LRU should be actualized
  """

  def get(key, touch \\ true) do
    case :ets.lookup(:cache, key) do
      [{_, _, value}] ->
        touch && Agent.get(:cache, __MODULE__, :handle_touch, [key])
        value

      [] ->
        nil
    end
  end

  def handle_touch(state = %{table: table}, key) do
    delete_timetable(state, key)
    uniq = insert_timetable(state, key)
    :ets.update_element(table, key, [{2, uniq}])
    :ok
  end

  @doc """
  Removes the entry stored under the given `key` from cache. Created for some testing
  """

  def delete(key),
    do: Agent.get(:cache, __MODULE__, :handle_delete, [key])

  def handle_delete(state = %{table: table}, key) do
    delete_timetable(state, key)
    :ets.delete(table, key)
    :ok
  end
end
