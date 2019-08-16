defmodule Fridge.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Supervisor.init(children(), strategy: :rest_for_one)
  end

  defp children do
    [
      {NoHumanFridge, name: NoHumanFridge}
    ]
  end
end
