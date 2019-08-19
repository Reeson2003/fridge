defmodule Fridge.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(children(), strategy: :one_for_one)
  end

  defp children do
    [
      {Fridge, name: Fridge},
      {NoHumanFridge, name: NoHumanFridge},
      {VeganFridge, name: VeganFridge}
    ]
  end

end
