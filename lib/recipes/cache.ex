defmodule Recipes.Cache do
  @moduledoc false
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def put(pid, key, value) do
    GenServer.cast(pid, {:put, key, value})
  end

  @impl true
  def init(_) do
    table = :ets.new(__MODULE__, [:set, :named_table])
    {:ok, table}
  end

  @impl true
  def handle_call({:get, key}, _from, table) do
    case :ets.lookup(table, key) do
      [{^key, value}] -> {:reply, {:ok, value}, table}
      [] -> {:reply, {:error, :not_found}, table}
    end
  end

  @impl true
  def handle_cast({:put, key, value}, table) do
    :ets.insert(table, {key, value})
    {:noreply, table}
  end
end
