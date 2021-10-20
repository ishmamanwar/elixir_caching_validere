defmodule ElixirCachingValidereTest do
  use ExUnit.Case
  # doctest ElixirCachingValidere

  test "GET PUT works" do
    assert {:ok, _} = ElixirCachingValidere.start_link(:test1, 2)
    assert :ok = ElixirCachingValidere.put(:test1, 1, "value")
    assert "value" = ElixirCachingValidere.get(:test1, 1)
    assert nil == ElixirCachingValidere.get(:test1, 2)
  end

  test "DELETE works" do
    ElixirCachingValidere.start_link(:test2, 2)
    ElixirCachingValidere.put(:test2, 1, "value")
    assert :ok = ElixirCachingValidere.delete(:test2, 1)
    assert :ok = ElixirCachingValidere.delete(:test2, 2)
    assert nil == ElixirCachingValidere.get(:test2, 1)
  end

  test "any object as `value` works" do
    assert {:ok, _} = ElixirCachingValidere.start_link(:test3, 2)
    assert :ok = ElixirCachingValidere.put(:test3, 1, "value")
    assert :ok = ElixirCachingValidere.put(:test3, 2, 2)
    assert "value" = ElixirCachingValidere.get(:test3, 1)
    assert(2 == ElixirCachingValidere.get(:test3, 2))
  end

  test "cache limit works" do
    assert {:ok, _} = ElixirCachingValidere.start_link(:test4, 5)
    Enum.map(1..5, &ElixirCachingValidere.put(:test4, &1, "value #{&1}"))
    assert "value 1" = ElixirCachingValidere.get(:test4, 1)
    Enum.map(6..10, &ElixirCachingValidere.put(:test4, &1, "value #{&1}"))
    assert nil == ElixirCachingValidere.get(:test4, 5)
    assert "value 6" = ElixirCachingValidere.get(:test4, 6)
  end

  test "eviction works" do
    test_pid = self()

    evict_fun = fn k, v ->
      send(test_pid, {:evicted, k, v})
    end

    ElixirCachingValidere.start_link(:test5, 3, evict_fn: evict_fun)

    ElixirCachingValidere.put(:test5, :a, 1)
    ElixirCachingValidere.put(:test5, :b, 2)
    ElixirCachingValidere.put(:test5, :c, 3)
    ElixirCachingValidere.put(:test5, :d, 4)
    ElixirCachingValidere.put(:test5, :e, 5)

    assert_received {:evicted, :a, 1}
    assert_received {:evicted, :b, 2}
    refute_received {:evicted, :c, 3}
  end



end
