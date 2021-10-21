defmodule ElixirCachingValidere.LruCache do

  use GenServer

  defstruct table: nil, time_table: nil, size: 0, evict_fn: nil

  def get_all(key) do
    ElixirCachingValidere.LruCache.start_link(:cache, 2) # new cache process with 2 items max limit
    ElixirCachingValidere.LruCache.put(:cache, "a", 1) # put a->1 { a: 1 }
    ElixirCachingValidere.LruCache.put(:cache, "b", 2) # put b->2 { a: 1, b: 2 }
    ElixirCachingValidere.LruCache.put(:cache, "c", 3) # can't put c, deleting a, and putting c { b: 2, c: 3}
    ElixirCachingValidere.LruCache.put(:cache, "d", 4) # can't put d, deleting b, and putting d { c: 3, d: 4}
    ElixirCachingValidere.LruCache.put(:cache, "d", 5) # updating d { c: 3, d: 5}

    #IO.inspect(ElixirCachingValidere.LruCache.get(:test1, :c))
    ElixirCachingValidere.LruCache.get_value(key)

  end

  def start_link(name, size, opts \\ []) do
    Agent.start_link(__MODULE__, :init, [name, size, opts], name: name)
  end

  def init(name, size, opts \\ []) do
    time_table = :"#{name}_timetable"
    :ets.new(time_table, [:named_table, :ordered_set])
    :ets.new(name, [:named_table, :public, {:read_concurrency, true}])
    evict_fn = Keyword.get(opts, :evict_fn)
    %ElixirCachingValidere.LruCache{time_table: time_table, table: name, size: size, evict_fn: evict_fn}
  end

  def init({name, size, opts}) do
    init(name, size, opts)
  end

  def put(name, key, value),
    do: Agent.get(name, __MODULE__, :handle_put, [key, value])

  def handle_put(state = %{table: table}, key, value) do
    delete_timetable(state, key)
    uniq = insert_timetable(state, key)
    :ets.insert(table, {key, uniq, value})
    reset_values(state)
    :ok
  end

  defp delete_timetable(%{time_table: time_table, table: table}, key) do
    case :ets.lookup(table, key) do
      [{_, old_uniq, _}] ->
        :ets.delete(time_table, old_uniq)

      _ ->
        nil
    end
  end

  defp insert_timetable(%{time_table: time_table}, key) do
    position = :erlang.unique_integer([:monotonic])
    :ets.insert(time_table, {position, key})
    position
  end

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

  def get(name, key, touch \\ true) do
    case :ets.lookup(name, key) do
      [{_, _, value}] ->
        touch && Agent.get(name, __MODULE__, :handle_touch, [key])
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

  def delete(name, key),
    do: Agent.get(name, __MODULE__, :handle_delete, [key])

  def handle_delete(state = %{table: table}, key) do
    delete_timetable(state, key)
    :ets.delete(table, key)
    :ok
  end

  def get_value(key) do
    ElixirCachingValidere.LruCache.get(:cache, key)
  end
end
