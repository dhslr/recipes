defmodule Recipes.SeleniumServer do
  use GenServer

  def start_link(_) do
    Process.flag(:trap_exit, true)
    case Process.whereis(__MODULE__) do
      nil -> start()
      pid -> {:error, {:already_started, pid}}
    end
  end

  defp start() do
    port = Port.open({:spawn, "selenium-server -port 4444"}, [:binary, :exit_status])
    # Wait for server startup
    Process.sleep(2000)
    GenServer.start_link(__MODULE__, %{port: port})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def terminate(_reason, %{port: existing_port}) do
    Port.close(existing_port)
    :ok
  end

end
