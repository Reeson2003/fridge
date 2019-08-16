defmodule NoHumanFridge do
  use GenServer
  @human "human"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  def delete(server, name) do
    GenServer.cast(server, {:delete, name})
  end

  def init(:ok) do
    IO.puts("Started NoHumanFridge: #{inspect self}")
    {:ok, %{}}
  end

  def handle_call({:lookup, name}, _from, state) do
    {:reply, Map.fetch(state, name), state}
  end

  #  %{:type => "human", :name => "Oleg"}
  #  %{:type => "fruit", :name => "apple"}

  def handle_cast({:create, %{:type => type, :name => name, expiry_date: expiry_date}}, state) do
    if type == @human do
      state
    else
      case Map.fetch(state, name) do
        :error -> {:noreply, Map.put(state, name, 1)}
        {:ok, number} -> {:noreply, Map.put(state, name, number + 1)}
      end
    end
  end

  def handle_cast({:delete, name}, state) do
    case Map.fetch(state, name) do
      :error -> {:noreply, state}
      {:ok, number} -> if number == 1 do
                         {:noreply, Map.delete(state, name)}
                       else
                         {:noreply, Map.put(state, name, number - 1)}
                       end
    end
  end

  def handle_info(_msg, state) do
    IO.puts("ICE")
    {:noreply, state}
  end

end

# NoHumanFridge.create(NoHumanFridge, %{:type => "fruit", :name => "apple", :expiry_date =>  ~N[2000-01-01 00:00:00]})
# NoHumanFridge.lookup(NoHumanFridge, "apple")
# NoHumanFridge.delete(NoHumanFridge, "apple")
