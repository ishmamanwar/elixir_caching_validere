defmodule ElixirCachingValidereTest do
  use ExUnit.Case
  # doctest ElixirCachingValidere

  test "general functions work" do
    assert {:ok, _} = ElixirCachingValidere.start_link(2)
    assert :ok = ElixirCachingValidere.put(1, "value")
    assert "value" = ElixirCachingValidere.get(1)
    assert nil == ElixirCachingValidere.get(2)
  end

  test "DELETE works" do
    ElixirCachingValidere.start_link(2)
    ElixirCachingValidere.put(1, "value")
    assert :ok = ElixirCachingValidere.delete(1)
    assert :ok = ElixirCachingValidere.delete(2)
    assert nil == ElixirCachingValidere.get(1)
  end

  test "any object as `value` works" do
    assert {:ok, _} = ElixirCachingValidere.start_link(2)
    assert :ok = ElixirCachingValidere.put(1, "value")
    assert :ok = ElixirCachingValidere.put(2, 2)
    assert "value" = ElixirCachingValidere.get(1)
    assert(2 == ElixirCachingValidere.get(2))
  end

  test "cache limit works" do
    assert {:ok, _} = ElixirCachingValidere.start_link(5)
    Enum.map(1..5, &ElixirCachingValidere.put(&1, "value #{&1}"))
    assert "value 1" = ElixirCachingValidere.get(1)
    Enum.map(6..10, &ElixirCachingValidere.put(&1, "value #{&1}"))
    assert nil == ElixirCachingValidere.get(5)
    assert "value 6" = ElixirCachingValidere.get(6)
  end

  test "eviction works" do
    test_pid = self()

    evict_fun = fn k, v ->
      send(test_pid, {:evicted, k, v})
    end

    ElixirCachingValidere.start_link(3, evict_fn: evict_fun)

    ElixirCachingValidere.put(:a, 1)
    ElixirCachingValidere.put(:b, 2)
    ElixirCachingValidere.put(:c, 3)
    ElixirCachingValidere.put(:d, 4)
    ElixirCachingValidere.put(:e, 5)

    assert_received {:evicted, :a, 1}
    assert_received {:evicted, :b, 2}
    refute_received {:evicted, :c, 3}
  end



end
