defmodule Fridge do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  def init(:ok) do
    IO.puts("Started fridge: #{inspect self}")
    {:ok, %{}}
  end

  def handle_call({:lookup, name}, _from, state) do
    IO.puts("LOOKUP")
    {:reply, Map.fetch(state, name), state}
  end

  def handle_cast({:create, name}, state) do
    IO.puts("CREATE")
    case Map.fetch(state, name) do
      :error -> {:noreply, Map.put(state, name, 1)}
      {:ok, number} -> {:noreply, Map.put(state, name, number + 1)}
    end
  end

  def handle_info(_msg, state) do
    IO.puts("ICE")
    {:noreply, state}
  end
end
