defmodule Fridge do
  use GenServer
  @reply :reply
  @noreply :noreply
  @lookup :lookup
  @create :create
  @delete :delete
  @clean :clean

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, name) do
    GenServer.call(server, {@lookup, name})
  end

  def lookup(server) do
    GenServer.call(server, @lookup)
  end

  def create(server, name) do
    GenServer.cast(server, {@create, name})
  end

  def delete(server, food = %{:name => _, expiry_date: _}) do
    GenServer.cast(server, {@delete, food})
  end

  defp clean(server) do
    GenServer.cast(server, @delete)
    Process.send_after(self, @clean, 1000)
  end

  def init(:ok) do
    IO.puts("Started Fridge: #{inspect self}")
    clean(self)
    {:ok, %{}}
  end

  def handle_call({@lookup, name}, _from, state) do
    result = case Map.fetch(state, name) do
      :error -> "#{name} not found"
      {:ok, expiry_date_list} -> Enum.map(expiry_date_list, fn x -> "Name: #{name}, expiry date: #{x}" end)
    end
    {@reply, result, state}
  end

  def handle_call(@lookup, _from, state) do
    result = Enum.reduce(
      state,
      [],
      fn {name, expiry_date_list}, acc ->
        acc ++ List.wrap(Enum.map(expiry_date_list, fn x -> "Name: #{name}, expiry date: #{x}" end))
      end
    )
    {@reply, result, state}
  end

  def handle_cast({@create, %{:type => type, :name => name, expiry_date: expiry_date}}, state) do
    case Map.fetch(state, name) do
      :error -> {@noreply, Map.put(state, name, [expiry_date])}
      {:ok, expiry_date_list} -> {@noreply, Map.put(state, name, expiry_date_list ++ [expiry_date])}
    end
  end

  def handle_cast(@delete, state) do
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
    {@noreply, state}
  end

  def handle_info(msg, state) do
    case msg do
      @clean -> clean(self)
      _ -> IO.puts("ICE")
    end
    {@noreply, state}
  end

end

# NaiveDateTime.utc_now()
# Fridge.create(Fridge, %{:type => "fruit", :name => "apple", :expiry_date =>  ~N[2000-01-01 00:00:00]})
# Fridge.lookup(Fridge, "apple")
