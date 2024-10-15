defmodule Recipes.CacheTest do
  use ExUnit.Case

  alias Recipes.Cache

  setup do
    {:ok, pid} = Cache.start_link(nil)
    %{pid: pid}
  end

  test "get/1 returns :error when key is not found", %{pid: pid} do
    assert {:error, :not_found} == Cache.get(pid, :not_found)
  end

  test "get/1 returns the value for a key", %{pid: pid} do
    assert :ok == Cache.put(pid, :key, :value)
    assert {:ok, :value} == Cache.get(pid, :key)
  end

  test "get/1 returns the latest value for a key", %{pid: pid} do
    assert :ok == Cache.put(pid, :key, :value)
    assert :ok == Cache.put(pid, :key, :new_value)
    assert {:ok, :new_value} == Cache.get(pid, :key)
  end

  test "put/2 stores a value", %{pid: pid} do
    assert :ok == Cache.put(pid, :key, :value)
    assert {:ok, :value} == Cache.get(pid, :key)
  end

  test "put/2 overwrites the value for a key", %{pid: pid} do
    assert :ok == Cache.put(pid, :key, :value)
    assert :ok == Cache.put(pid, :key, :new_value)
    assert {:ok, :new_value} == Cache.get(pid, :key)
  end
end
