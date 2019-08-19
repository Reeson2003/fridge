defmodule VeganFridge do
  use GenServer
  @seafood "seafood"
  @meat "meat"

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
    IO.puts("Started VeganFridge: #{inspect self}")
    Process.send_after(self, :delete, 1000)
    {:ok, %{}}
  end

  def handle_call({:lookup, name}, _from, state) do
    result = case Map.fetch(state, name) do
      :error -> "#{name} not found"
      {:ok, expiry_date_list} -> Enum.map(expiry_date_list, fn x -> "Name: #{name}, expiry date: #{x}" end)
    end
    {:reply, result, state}
  end

  def handle_cast({:create, %{:type => type, :name => name, expiry_date: expiry_date}}, state) do
    if type == @seafood || type == @meat do
      {:noreply, state}
    else
      case Map.fetch(state, name) do
        :error -> {:noreply, Map.put(state, name, [expiry_date])}
        {:ok, expiry_date_list} -> {:noreply, Map.put(state, name, expiry_date_list ++ [expiry_date])}
      end
    end
  end

  def handle_info(:delete, state) do
    expiry_date = NaiveDateTime.utc_now()
    state = Enum.reduce(
      state,
      %{},
      fn {name, expiry_dates}, acc ->
        remain = Enum.filter(
          expiry_dates,
          fn date -> case NaiveDateTime.compare(date, expiry_date) do
                       :gt -> true
                       _ ->
                         IO.puts("Dropped: #{name}, expiry date: #{date}")
                         false
                     end
          end
        )
        if Enum.empty?(remain) do
          acc
        else
          Map.put(acc, name, remain)
        end
      end
    )
    Process.send_after(self, :delete, 1000)
    {:noreply, state}
  end

end
